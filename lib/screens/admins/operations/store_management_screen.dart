import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/store_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class StoreManagementScreen extends StatelessWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<StoreController>(context);

    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi cửa hàng: ${controller.errorMessage!}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          controller.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const SidebarWidget(),
          Expanded(
            child: Column(
              children: [
                const HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(context),
                        const SizedBox(height: 32),
                        _buildFilterSection(context),
                        const SizedBox(height: 32),
                        const _StoreContentLayout(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "QUẢN LÝ CỬA HÀNG",
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              "Sản phẩm & Tồn kho",
              style: TextStyle(
                color: Color(0xFF0A192F),
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showProductDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("Thêm sản phẩm mới"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final controller = context.watch<StoreController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => context.read<StoreController>().setSearchQuery(v),
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ['Tất cả', 'Supplements', 'Equipment', 'Apparel', 'Drinks'].map((category) {
                final isSelected = controller.selectedCategory == category;
                return GestureDetector(
                  onTap: () => controller.setCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                          : null,
                    ),
                    child: Text(
                      category == 'Tất cả' ? 'Tất cả' : category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF0A192F) : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, {ProductModel? product}) {
    final controller = context.read<StoreController>();
    final nameController = TextEditingController(text: product?.name);
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stock.toString());
    final imageController = TextEditingController(text: product?.imageUrl);
    final descController = TextEditingController(text: product?.description);
    String selectedCat = product?.category ?? 'Supplements';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(product == null ? "Thêm sản phẩm" : "Cập nhật sản phẩm"),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên sản phẩm")),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: "Danh mục"),
                    items: ['Supplements', 'Equipment', 'Apparel', 'Drinks']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCat = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Giá bán (VNĐ)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Số lượng tồn kho"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả")),
                  const SizedBox(height: 12),
                  TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Hình ảnh")),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                final newProduct = ProductModel(
                  id: product?.id ?? "",
                  name: nameController.text.trim(),
                  category: selectedCat,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stock: int.tryParse(stockController.text) ?? 0,
                  imageUrl: imageController.text.trim().isNotEmpty ? imageController.text.trim() : null,
                  description: descController.text.trim(),
                );

                if (product == null) {
                  await controller.addProduct(newProduct);
                } else {
                  await controller.updateProduct(newProduct);
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: const Text("Lưu sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreContentLayout extends StatelessWidget {
  const _StoreContentLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 8, child: _ProductGrid()),
        SizedBox(width: 24),
        Expanded(flex: 4, child: _StoreStatsPanel()),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoreController>();
    final products = controller.products;

    if (controller.isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: CircularProgressIndicator(),
      ));
    }

    if (products.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Text('Không có sản phẩm nào khớp với tìm kiếm'),
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 300,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl ?? 'https://via.placeholder.com/200',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, color: Colors.grey, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stock > 5 ? const Color(0xFF10B981) : Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.stock > 0 ? "Kho: ${product.stock}" : "Hết hàng",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 10, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF0A192F), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(color: Color(0xFF0A192F), fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showEditDialog(context),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                          style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.05)),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    const StoreManagementScreen()._showProductDialog(context, product: product);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa sản phẩm '${product.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await context.read<StoreController>().deleteProduct(product.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StoreStatsPanel extends StatelessWidget {
  const _StoreStatsPanel();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoreController>();
    final products = controller.products;
    final lowStockCount = products.where((p) => p.stock <= 5).length;
    final totalInventoryValue = products.fold(0.0, (sum, p) => sum + (p.price * p.stock));
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THỐNG KÊ CỬA HÀNG',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 24),
          _statItem(context, "Tổng số sản phẩm", "${products.length} mục", Icons.inventory_2_outlined, Colors.blue),
          const SizedBox(height: 16),
          _statItem(context, "Sản phẩm sắp hết", "$lowStockCount mục", Icons.warning_amber_rounded, Colors.orange),
          const SizedBox(height: 16),
          _statItem(context, "Giá trị tồn kho", currencyFormat.format(totalInventoryValue), Icons.account_balance_wallet_outlined, Colors.green),
          const SizedBox(height: 32),
          const Text(
            'GIAO DỊCH GẦN ĐÂY',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 16),
          _recentOrder("Protein Whey Isolate", "950,000₫", "Vừa xong"),
          _recentOrder("Găng tay Harbinger", "350,000₫", "15 phút trước"),
          _recentOrder("Nước điện giải", "15,000₫", "1 giờ trước"),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A192F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("XEM BÁO CÁO CHI TIẾT"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _recentOrder(String name, String price, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
        ],
      ),
    );
  }
}
