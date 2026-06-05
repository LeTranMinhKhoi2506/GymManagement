import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/membership_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../data/models/product_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/member_model.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
    );

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

      // 3. Update customer LTV + activity log if registered
      if (_selectedCustomer != null) {
        final memberRef = firestore.collection('members').doc(customerId);
        batch.update(memberRef, {
          'ltv': FieldValue.increment(totalAmount),
        });

        // Activity log with correct type (Product or Membership)
        final activityRef = memberRef.collection('activity_logs').doc();
        batch.set(activityRef, {
          'title': 'Mua hàng tại quầy',
          'timestamp': FieldValue.serverTimestamp(),
          'amount': totalAmount,
          'status': 'Paid',
          'type': paymentType,
        });
      }

      // Commit all operations atomically — all-or-nothing
      await batch.commit();

      // Refresh payment list in controller
      if (mounted) {
        final paymentController = Provider.of<PaymentController>(context, listen: false);
        await paymentController.fetchAllPayments();
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading indicator
      
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

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thanh toán: $e"), backgroundColor: Colors.redAccent),
      );
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
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView(
                shrinkWrap: true,
                children: customerController.allMembers.where((m) {
                  return m.fullName.toLowerCase().contains(_customerSearchQuery) ||
                      (m.phoneNumber ?? '').contains(_customerSearchQuery);
                }).map((m) {
                  return ListTile(
                    dense: true,
                    title: Text(m.fullName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(m.membershipType, style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      setState(() {
                        _selectedCustomer = m;
                        _customerSearchQuery = '';
                      });
                      setSheetState(() {});
                    },
                  );
                }).toList(),
              ),
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

    return Scaffold(
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
}
