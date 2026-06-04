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

    final paymentController = Provider.of<PaymentController>(context, listen: false);
    final storeController = Provider.of<StoreController>(context, listen: false);

    String customerId = _selectedCustomer?.id ?? 'GUEST';
    String customerName = _selectedCustomer?.fullName ?? 'Khách vãng lai';
    double totalAmount = _calculateTotal();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
    );

    try {
      // 1. Create payment using payment controller
      await paymentController.createPayment(
        memberId: customerId,
        memberName: customerName,
        membershipType: _selectedCustomer?.membershipType ?? 'Retail Item',
        amount: totalAmount,
        dueDate: DateTime.now(),
        paymentType: _cartItems.values.first is MembershipPlan ? 'Membership' : 'Product',
        notes: 'Mua tại quầy lễ tân. PT thức: $method',
      );

      // Since payment starts as Pending, we can mark it as Paid immediately
      if (paymentController.payments.isNotEmpty) {
        final lastPayment = paymentController.payments.first;
        await paymentController.markPaymentAsPaid(lastPayment.id, method);
      }

      // 2. Reduce stock for items in cart
      for (var entry in _cart.entries) {
        final item = _cartItems[entry.key];
        final qty = entry.value;

        if (item is ProductModel) {
          int newStock = item.stock - qty;
          if (newStock < 0) newStock = 0;
          await FirebaseFirestore.instance.collection('products').doc(item.id).update({
            'stock': newStock,
          });
        }
      }

      // 3. Update customer LTV in Firestore if registered
      if (_selectedCustomer != null) {
        await FirebaseFirestore.instance.collection('members').doc(customerId).update({
          'ltv': _selectedCustomer!.ltv + totalAmount,
        });

        // Log transaction inside customer logs
        await FirebaseFirestore.instance
            .collection('members')
            .doc(customerId)
            .collection('activity_logs')
            .add({
          'title': 'Mua hàng tại quầy',
          'timestamp': FieldValue.serverTimestamp(),
          'amount': totalAmount,
          'status': 'Paid',
          'type': 'Product',
        });
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

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final membershipController = Provider.of<MembershipController>(context);
    final customerController = Provider.of<CustomerController>(context);

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
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900), // Responsive desktop grid
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Products & Passes Grid
                Expanded(
                  flex: 3,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Products Tab
                      GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: storeController.products.length,
                        itemBuilder: (context, index) {
                          final product = storeController.products[index];
                          return _buildProductCard(product, formatter);
                        },
                      ),

                      // Membership Plans Tab
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

                // Interactive Cart Panel
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      border: Border(left: BorderSide(color: Colors.white10)),
                    ),
                    child: Column(
                      children: [
                        _buildCustomerSelector(customerController),
                        const Divider(color: Colors.white10, height: 1),
                        Expanded(child: _buildCartList(formatter)),
                        _buildSummaryPanel(formatter),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, NumberFormat formatter) {
    bool outOfStock = product.stock <= 0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
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
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(product.price),
                  style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      outOfStock ? "Hết hàng" : "Kho: ${product.stock}",
                      style: TextStyle(color: outOfStock ? Colors.redAccent : Colors.grey, fontSize: 10),
                    ),
                    GestureDetector(
                      onTap: outOfStock ? null : () => _addToCart(product.id, product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: outOfStock ? Colors.grey[850] : const Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  "Thời hạn: ${plan.durationMonths} Tháng ${plan.hasPT ? '• Kèm PT' : ''}",
                  style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 11, fontWeight: FontWeight.w500),
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
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _addToCart(plan.id, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("CHỌN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(CustomerController customerController) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "KHÁCH HÀNG MUA",
            style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          _selectedCustomer == null
              ? TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) {
                    setState(() {
                      _customerSearchQuery = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm thành viên (SĐT / Tên)...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_search, color: Colors.grey, size: 20),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Gói tập hiện tại: ${_selectedCustomer!.membershipType}",
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                        onPressed: () => setState(() => _selectedCustomer = null),
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
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartList(NumberFormat formatter) {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 40),
            SizedBox(height: 8),
            Text("Giỏ hàng đang trống", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: _cart.entries.map((entry) {
        final item = _cartItems[entry.key];
        String name = '';
        double price = 0;

        if (item is ProductModel) {
          name = item.name;
          price = item.price;
        } else if (item is MembershipPlan) {
          name = planNameShort(item.name);
          price = item.price;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(price),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                    onPressed: () => _removeFromCart(entry.key),
                  ),
                  Text(
                    "${entry.value}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6B35), size: 20),
                    onPressed: () => _addToCart(entry.key, item),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  String planNameShort(String fullName) {
    if (fullName.length > 20) {
      return "${fullName.substring(0, 18)}...";
    }
    return fullName;
  }

  Widget _buildSummaryPanel(NumberFormat formatter) {
    double total = _calculateTotal();
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TỔNG CỘNG:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                formatter.format(total),
                style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: total <= 0 ? null : () => _showPaymentDrawer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    disabledBackgroundColor: Colors.grey[850],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showPaymentDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
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
                  Navigator.pop(context);
                  _checkout(context, 'Cash');
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: Colors.cyanAccent),
                title: const Text("Chuyển khoản QR", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _checkout(context, 'Transfer');
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.credit_card_rounded, color: Colors.orangeAccent),
                title: const Text("Quẹt thẻ ngân hàng", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
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
