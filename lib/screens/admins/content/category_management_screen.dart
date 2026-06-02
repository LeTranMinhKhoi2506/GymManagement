import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/category_controller.dart';
import '../../../data/models/category_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'Content';

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);

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
                        _buildHeader(categoryController),
                        const SizedBox(height: 32),
                        _buildCategoryTable(categoryController),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CategoryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quản lý danh mục", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            Text("Quản lý các nhóm phân loại cho nội dung và tài sản", style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddCategoryDialog(controller),
          icon: const Icon(Icons.add_box_outlined),
          label: const Text("Thêm danh mục"),
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

  Widget _buildCategoryTable(CategoryController controller) {
    if (controller.categories.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text("Chưa có danh mục nào.")));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("TÊN DANH MỤC")),
          DataColumn(label: Text("LOẠI")),
          DataColumn(label: Text("SỐ LƯỢNG")),
          DataColumn(label: Text("THAO TÁC")),
        ],
        rows: controller.categories.map((cat) => DataRow(cells: [
          DataCell(Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(8)),
            child: Text(cat.type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          )),
          DataCell(Text("${cat.itemCount} mục")),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                onPressed: () => _showAddCategoryDialog(controller, category: cat),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _showDeleteConfirmDialog(controller, cat),
              ),
            ],
          )),
        ])).toList(),
      ),
    );
  }

  void _showAddCategoryDialog(CategoryController controller, {CategoryModel? category}) {
    _nameController.text = category?.name ?? '';
    String currentType = category?.type ?? _selectedType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(category == null ? "Thêm danh mục mới" : "Chỉnh sửa danh mục"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên danh mục (VD: Máy Cardio)"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: currentType,
                items: const [
                  DropdownMenuItem(value: 'Content', child: Text("Nội dung/Bài viết")),
                  DropdownMenuItem(value: 'Equipment', child: Text("Trang thiết bị")),
                  DropdownMenuItem(value: 'Product', child: Text("Sản phẩm cửa hàng")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      currentType = val;
                      _selectedType = val;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: "Phân loại"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  if (category == null) {
                    controller.addCategory(_nameController.text, currentType);
                  } else {
                    controller.updateCategory(CategoryModel(
                      id: category.id,
                      name: _nameController.text,
                      type: currentType,
                      itemCount: category.itemCount,
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
              child: Text(category == null ? "Thêm ngay" : "Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(CategoryController controller, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa danh mục"),
        content: Text("Bạn có chắc chắn muốn xóa danh mục '${cat.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              controller.deleteCategory(cat.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}
