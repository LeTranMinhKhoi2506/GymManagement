import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/membership_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/financial_controller.dart';
import '../../data/models/product_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/member_model.dart';
import '../../data/services/momo_service.dart';

class ReceptionistPOSScreen extends StatefulWidget {
  const ReceptionistPOSScreen({super.key});

  @override
  State<ReceptionistPOSScreen> createState() => _ReceptionistPOSScreenState();
}

class _ReceptionistPOSScreenState extends State<ReceptionistPOSScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _cart = {}; // Map of ItemId -> Quantity
  final Map<String, dynamic> _cartItems = {}; // Map of ItemId -> Model (ProductModel or MembershipPlan)
  MemberModel? _selectedCustomer; // Selected customer for checkout
  String _customerSearchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalCartItems {
    int total = 0;
    _cart.forEach((_, qty) => total += qty);
    return total;
  }

  void _addToCart(String id, dynamic item) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
      _cartItems[id] = item;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if (_cart.containsKey(id)) {
        if (_cart[id] == 1) {
          _cart.remove(id);
          _cartItems.remove(id);
        } else {
          _cart[id] = _cart[id]! - 1;
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    _cart.forEach((id, qty) {
      final item = _cartItems[id];
      if (item is ProductModel) {
        total += item.price * qty;
      } else if (item is MembershipPlan) {
        total += item.price * qty;
      }
    });
    return total;
  }

  void _checkout(BuildContext context, String method) async {
    if (_cart.isEmpty) return;

    String customerId = _selectedCustomer?.id ?? 'GUEST';
    String customerName = _selectedCustomer?.fullName ?? 'Khách vãng lai';
    double totalAmount = _calculateTotal();

    // Determine payment type based on cart contents
    bool hasMembership = _cartItems.values.any((item) => item is MembershipPlan);
    String paymentType = hasMembership ? 'Membership' : 'Product';

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // --- Validate stock before checkout ---
      for (var entry in _cart.entries) {
        final item = _cartItems[entry.key];
        if (item is ProductModel) {
          final doc = await firestore.collection('products').doc(item.id).get();
          final currentStock = doc.data()?['stock'] ?? 0;
          if (currentStock < entry.value) {
            throw Exception(
              'Sản phẩm "${item.name}" chỉ còn $currentStock trong kho, không đủ ${entry.value} để bán.',
            );
          }
        }
      }

      // --- Build atomic batch ---
      final batch = firestore.batch();

      // 1. Create payment document directly as Paid (no Pending→Paid roundtrip)
      final paymentRef = firestore.collection('payments').doc();
      batch.set(paymentRef, {
        'memberId': customerId,
        'memberName': customerName,
        'membershipType': _selectedCustomer?.membershipType ?? 'Retail Item',
        'amount': totalAmount,
        'dueDate': Timestamp.fromDate(DateTime.now()),
        'paymentDate': Timestamp.fromDate(DateTime.now()),
        'status': 'Paid',
        'paymentMethod': method,
        'paymentType': paymentType,
        'notes': 'Mua tại quầy lễ tân. Phương thức: $method',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 2. Reduce stock using FieldValue.increment (atomic, race-condition safe)
      for (var entry in _cart.entries) {
        final item = _cartItems[entry.key];
        final qty = entry.value;

        if (item is ProductModel) {
          final productRef = firestore.collection('products').doc(item.id);
          batch.update(productRef, {
            'stock': FieldValue.increment(-qty),
          });
        }
      }

      // Find the purchased MembershipPlan in the cart
      MembershipPlan? purchasedPlan;
      for (var entry in _cart.entries) {
        final item = _cartItems[entry.key];
        if (item is MembershipPlan) {
          purchasedPlan = item;
          break;
        }
      }

      // 1.5. Create transaction document for financial accounting
      final transactionRef = firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'type': 'Revenue',
        'category': paymentType, // 'Membership' or 'Product'
        'description': purchasedPlan != null 
            ? 'Đăng ký gói tập ${purchasedPlan.name} cho $customerName'
            : 'Bán lẻ sản phẩm tại quầy cho $customerName',
        'amount': totalAmount,
        'transactionDate': Timestamp.fromDate(DateTime.now()),
        'paymentMethod': method,
        'status': 'Completed',
        'relatedMemberId': customerId != 'GUEST' ? customerId : null,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'createdBy': 'Lễ tân (POS)',
        'notes': 'Hóa đơn bán hàng POS tại quầy. Phương thức: $method',
      });

      // 3. Update customer LTV + activity log + membership package if registered
      if (_selectedCustomer != null) {
        final memberRef = firestore.collection('members').doc(customerId);
        final Map<String, dynamic> setData = {
          'fullName': _selectedCustomer!.fullName,
          'email': _selectedCustomer!.email,
          'phoneNumber': _selectedCustomer!.phoneNumber,
          'ltv': FieldValue.increment(totalAmount),
          'memberSince': FieldValue.serverTimestamp(),
        };
        if (purchasedPlan != null) {
          setData['membershipType'] = purchasedPlan.name;
          setData['status'] = 'Active';
          setData['isCurrentlyTraining'] = true;
          setData['nextRenewal'] = Timestamp.fromDate(
            DateTime.now().add(Duration(days: purchasedPlan.durationMonths * 30)),
          );
        }
        batch.set(memberRef, setData, SetOptions(merge: true));

        // Activity log with correct type (Product or Membership)
        final activityRef = memberRef.collection('activity_logs').doc();
        batch.set(activityRef, {
          'title': purchasedPlan != null ? 'Đăng ký gói tập ${purchasedPlan.name}' : 'Mua hàng tại quầy',
          'timestamp': FieldValue.serverTimestamp(),
          'amount': totalAmount,
          'status': 'Paid',
          'type': paymentType,
        });
      }

      // Commit all operations atomically — all-or-nothing
      await batch.commit();

      // Refresh payment list and transaction lists in controllers
      if (mounted) {
        final paymentController = Provider.of<PaymentController>(context, listen: false);
        final financialController = Provider.of<FinancialController>(context, listen: false);
        await paymentController.fetchAllPayments();
        await financialController.fetchAllTransactions();
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (purchasedPlan != null && purchasedPlan.hasPT && _selectedCustomer != null) {
        final memberCopy = _selectedCustomer!;
        final planCopy = purchasedPlan;
        setState(() {
          _cart.clear();
          _cartItems.clear();
          _selectedCustomer = null;
        });
        _showPTSelectorBottomSheet(context, memberCopy, planCopy);
      } else {
        // Show Success Dialog
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
              const SizedBox(height: 16),
              const Text(
                "THANH TOÁN THÀNH CÔNG",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Hóa đơn trị giá ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount)} đã được thanh toán bằng $method.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _cart.clear();
                      _cartItems.clear();
                      _selectedCustomer = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("XONG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi thanh toán: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }


  void _openCartSheet() {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final customerController = Provider.of<CustomerController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            double total = _calculateTotal();
            bool hasMembership = _cartItems.values.any((item) => item is MembershipPlan);
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: Color(0xFFFF6B35), size: 22),
                            const SizedBox(width: 10),
                            Text(
                              "GIỎ HÀNG (${_totalCartItems})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        if (_cart.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _cart.clear();
                                _cartItems.clear();
                              });
                              setSheetState(() {});
                            },
                            child: const Text(
                              "Xóa tất cả",
                              style: TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  // Customer selector
                  _buildCustomerSelectorSheet(customerController, setSheetState),
                  const Divider(color: Colors.white10, height: 1),

                  // Cart items list
                  Expanded(
                    child: _cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 50),
                                SizedBox(height: 12),
                                Text(
                                  "Giỏ hàng đang trống",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Hãy thêm sản phẩm từ danh sách",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            children: _cart.entries.map((entry) {
                              final item = _cartItems[entry.key];
                              String name = '';
                              double price = 0;
                              String? imageUrl;

                              if (item is ProductModel) {
                                name = item.name;
                                price = item.price;
                                imageUrl = item.imageUrl;
                              } else if (item is MembershipPlan) {
                                name = item.name;
                                price = item.price;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    // Product image
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                              )
                                            : Icon(
                                                item is MembershipPlan
                                                    ? Icons.card_membership_rounded
                                                    : Icons.shopping_bag_outlined,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Name & price
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatter.format(price),
                                            style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Quantity controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C2C2E),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _removeFromCart(entry.key);
                                              setState(() {});
                                              setSheetState(() {});
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(Icons.remove, color: Colors.grey, size: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              "${entry.value}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _addToCart(entry.key, item);
                                              setSheetState(() {});
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(Icons.add, color: Color(0xFFFF6B35), size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  // Bottom summary: Total + Pay button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border(top: BorderSide(color: Colors.white10)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Total row — horizontal layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TỔNG CỘNG:",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                formatter.format(total),
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Pay button — full width
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: total <= 0
                                  ? null
                                  : () {
                                      if (hasMembership && _selectedCustomer == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Vui lòng chọn hoặc tìm kiếm thành viên trước khi thanh toán gói tập!"),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(builderContext);
                                      _showPaymentDrawer(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                disabledBackgroundColor: Colors.grey[850],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "THANH TOÁN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerSelectorSheet(CustomerController customerController, StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "KHÁCH HÀNG MUA",
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          _selectedCustomer == null
              ? TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _customerSearchQuery = val.toLowerCase();
                    });
                    setSheetState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm thành viên (SĐT / Tên)...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_search, color: Colors.grey, size: 20),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.greenAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCustomer!.fullName,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Gói tập hiện tại: ${_selectedCustomer!.membershipType}",
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                        onPressed: () {
                          setState(() => _selectedCustomer = null);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ),

          // Suggestions dropdown list
          if (_selectedCustomer == null && _customerSearchQuery.isNotEmpty)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', whereIn: const ['user', 'member'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final queryDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = (data['fullName'] ?? '').toString().toLowerCase();
                  final phone = (data['phoneNumber'] ?? data['phone'] ?? '').toString();
                  return fullName.contains(_customerSearchQuery.toLowerCase()) ||
                      phone.contains(_customerSearchQuery);
                }).toList();

                if (queryDocs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Text("Không tìm thấy người dùng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                }

                return Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: queryDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final fullName = data['fullName'] ?? '';
                      final email = data['email'] ?? '';
                      final phone = data['phoneNumber'] ?? data['phone'] ?? '';

                      String membershipType = 'Chưa đăng ký gói';
                      try {
                        final existingMember = customerController.allMembers.firstWhere((m) => m.id == id);
                        membershipType = existingMember.membershipType;
                      } catch (_) {}

                      return ListTile(
                        dense: true,
                        title: Text(fullName, style: const TextStyle(color: Colors.white)),
                        subtitle: Text("$membershipType • $phone", style: const TextStyle(color: Colors.grey)),
                        onTap: () {
                          setState(() {
                            _selectedCustomer = MemberModel(
                              id: id,
                              fullName: fullName,
                              email: email,
                              phoneNumber: phone,
                              membershipType: membershipType,
                              status: 'Inactive',
                            );
                            _customerSearchQuery = '';
                          });
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final membershipController = Provider.of<MembershipController>(context);

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              "BÁN HÀNG TẠI QUẦY (POS)",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            backgroundColor: const Color(0xFF1C1C1E),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              // Cart button with badge
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 26),
                      onPressed: _openCartSheet,
                      tooltip: "Giỏ hàng",
                    ),
                    if (_totalCartItems > 0)
                      Positioned(
                        top: 6,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            "$_totalCartItems",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF6B35),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "SẢN PHẨM"),
                Tab(text: "GÓI TẬP / THẺ"),
              ],
            ),
          ),
          // Bottom bar showing total — always visible
          bottomNavigationBar: _cart.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C1C1E),
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Total section
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "TỔNG CỘNG",
                                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatter.format(_calculateTotal()),
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Checkout button
                        ElevatedButton.icon(
                          onPressed: _openCartSheet,
                          icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                          label: Text(
                            "XEM GIỎ (${_totalCartItems})",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Products Tab — full width grid
              GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: storeController.products.length,
                itemBuilder: (context, index) {
                  final product = storeController.products[index];
                  return _buildProductCard(product, formatter);
                },
              ),

              // Membership Plans Tab — full width list
              ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: membershipController.plans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final plan = membershipController.plans[index];
                  return _buildPlanCard(plan, formatter);
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, NumberFormat formatter) {
    bool outOfStock = product.stock <= 0;
    int qtyInCart = _cart[product.id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: qtyInCart > 0 ? const Color(0xFFFF6B35).withValues(alpha: 0.6) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: product.imageUrl != null
                        ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 50))
                        : const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 50),
                  ),
                ),
                // Quantity badge on image
                if (qtyInCart > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "x$qtyInCart",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(product.price),
                  style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      outOfStock ? "Hết hàng" : "Kho: ${product.stock}",
                      style: TextStyle(color: outOfStock ? Colors.redAccent : Colors.grey, fontSize: 11),
                    ),
                    GestureDetector(
                      onTap: outOfStock ? null : () => _addToCart(product.id, product),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: outOfStock ? Colors.grey[850] : const Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlan plan, NumberFormat formatter) {
    int qtyInCart = _cart[plan.id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: qtyInCart > 0 ? const Color(0xFFFF6B35).withValues(alpha: 0.6) : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        plan.name,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (qtyInCart > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "x$qtyInCart",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "Thời hạn: ${plan.durationMonths} Tháng ${plan.hasPT ? '• Kèm PT' : ''}",
                  style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(plan.price),
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _addToCart(plan.id, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text("CHỌN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  String planNameShort(String fullName) {
    if (fullName.length > 20) {
      return "${fullName.substring(0, 18)}...";
    }
    return fullName;
  }

  void _showPaymentDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CHỌN PHƯƠNG THỨC THANH TOÁN",
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.money_rounded, color: Colors.greenAccent),
                title: const Text("Tiền mặt", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _checkout(context, 'Cash');
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: Colors.cyanAccent),
                title: const Text("Chuyển khoản QR", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _checkout(context, 'Transfer');
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded, color: Colors.pinkAccent),
                title: const Text("Thanh toán MoMo QR", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showMoMoQRDialog(context);
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.credit_card_rounded, color: Colors.orangeAccent),
                title: const Text("Quẹt thẻ ngân hàng", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _checkout(context, 'Card');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoMoQRDialog(BuildContext context) {
    final double totalAmount = _calculateTotal();
    final String orderId = "POS${DateTime.now().millisecondsSinceEpoch.toString()}";
    final String description = "Thanh toan don hang $orderId";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return MoMoQRDialog(
          amount: totalAmount,
          orderId: orderId,
          description: description,
          onSuccess: () {
            _checkout(context, 'MoMo QR');
          },
        );
      },
    );
  }

  void _showPTSelectorBottomSheet(BuildContext context, MemberModel member, MembershipPlan plan) {
    bool isAssigning = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(sheetCtx).size.height * 0.8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "CHỌN HUẤN LUYỆN VIÊN (PT)",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Gói tập '${plan.name}' yêu cầu gán HLV cho học viên ${member.fullName}.",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('role', whereIn: ['trainer', 'staff'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text("Lỗi tải danh sách PT", style: TextStyle(color: Colors.redAccent)));
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
                            }

                            final trainers = (snapshot.data?.docs ?? []).where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final role = data['role'] ?? '';
                              final position = data['position'] ?? '';
                              return role == 'trainer' || position == 'PT/Trainer' || position == 'trainer';
                            }).toList();

                            if (trainers.isEmpty) {
                              return const Center(
                                child: Text("Không có HLV/PT nào hoạt động", style: TextStyle(color: Colors.grey)),
                              );
                            }

                            return ListView.separated(
                              itemCount: trainers.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final doc = trainers[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final uid = doc.id;
                                final name = data['fullName'] ?? 'HLV/PT';
                                final imageUrl = data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=$uid';
                                final experience = data['experience'] ?? '3+ Yrs';

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey[900],
                                        child: ClipOval(
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: 48,
                                            height: 48,
                                            errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Kinh nghiệm: $experience",
                                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: isAssigning ? null : () async {
                                          setSheetState(() {
                                            isAssigning = true;
                                          });
                                          try {
                                            await _assignPT(sheetCtx, member, plan, uid, name);
                                          } catch (e) {
                                            // error handled inside _assignPT
                                          } finally {
                                            if (sheetCtx.mounted) {
                                              setSheetState(() {
                                                isAssigning = false;
                                              });
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF6B35),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                        child: const Text("CHỌN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAssigning)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _assignPT(BuildContext sheetContext, MemberModel member, MembershipPlan plan, String ptId, String ptName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final studentRef = firestore.collection('students').doc();
      final remainingSessions = plan.durationMonths * 4;
      final startedAt = DateTime.now();
      final endAt = DateTime.now().add(Duration(days: plan.durationMonths * 30));

      batch.set(studentRef, {
        'ptId': ptId,
        'memberId': member.id,
        'name': member.fullName,
        'goal': 'HYPERTROPHY',
        'lastSession': 'Chưa dạy',
        'remainingSessions': remainingSessions,
        'photoUrl': member.profileImageUrl ?? 'https://i.pravatar.cc/150?u=${member.id}',
        'phone': member.phoneNumber ?? '',
        'amount': plan.price,
        'createdAt': FieldValue.serverTimestamp(),
        'startedAt': Timestamp.fromDate(startedAt),
        'endAt': Timestamp.fromDate(endAt),
      });

      final memberRef = firestore.collection('members').doc(member.id);
      batch.update(memberRef, {
        'ptId': ptId,
        'ptName': ptName,
      });

      final ptActivityRef = firestore.collection('pt_activities').doc();
      batch.set(ptActivityRef, {
        'ptId': ptId,
        'type': 'booking',
        'title': 'Học viên mới được phân công',
        'subtitle': 'Học viên ${member.fullName} đã đăng ký gói tập và được phân công cho bạn.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(sheetContext); // Close PT selector sheet

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
              const SizedBox(height: 16),
              const Text(
                "THANH TOÁN & GÁN PT THÀNH CÔNG",
                style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Học viên ${member.fullName} đã được gán cho PT $ptName với số buổi có PT là $remainingSessions buổi.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("XONG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(sheetContext).showSnackBar(
          SnackBar(content: Text("Lỗi gán PT: $e"), backgroundColor: Colors.redAccent),
        );
      }
      rethrow;
    }
  }
}

class MoMoQRDialog extends StatefulWidget {
  final double amount;
  final String orderId;
  final String description;
  final VoidCallback onSuccess;

  const MoMoQRDialog({
    super.key,
    required this.amount,
    required this.orderId,
    required this.description,
    required this.onSuccess,
  });

  @override
  State<MoMoQRDialog> createState() => _MoMoQRDialogState();
}

class _MoMoQRDialogState extends State<MoMoQRDialog> {
  late Future<String?> _momoPaymentFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _momoPaymentFuture = MomoService().createMomoPayment(
      amount: widget.amount,
      orderId: widget.orderId,
      description: widget.description,
    );
    
    // Start polling status
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final bool isPaid = await MomoService().checkPaymentStatus(widget.orderId);
      if (isPaid) {
        _pollingTimer?.cancel();
        if (mounted) {
          Navigator.pop(context); // Close dialog
          widget.onSuccess(); // Run checkout success callback
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFD82D8B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "M",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "THANH TOÁN MOMO QR",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
      content: FutureBuilder<String?>(
        future: _momoPaymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFD82D8B)),
              ),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Lỗi kết nối cổng thanh toán:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final String? payUrl = snapshot.data;
          if (payUrl == null || payUrl.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Không thể khởi tạo link thanh toán từ MoMo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final String qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(payUrl)}";

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Quét mã QR dưới đây để đi đến trang thanh toán test của MoMo. Khi quét và xác nhận xong trên MoMo, đơn hàng sẽ tự động hoàn tất.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                
                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    qrUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFD82D8B)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Details Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Đối tác:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const Text("MoMo Sandbox", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Số tiền:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            formatter.format(widget.amount),
                            style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Mã đơn hàng:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.orderId, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        // Confirm button (enabled only when we have data, as backup helper)
        FutureBuilder<String?>(
          future: _momoPaymentFuture,
          builder: (context, snapshot) {
            final bool hasData = snapshot.hasData && snapshot.data != null;
            return ElevatedButton(
              onPressed: !hasData
                  ? null
                  : () {
                      _pollingTimer?.cancel();
                      Navigator.pop(context);
                      widget.onSuccess();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD82D8B),
                disabledBackgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Xác nhận đã nhận tiền", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            );
          },
        ),
      ],
    );
  }
}
