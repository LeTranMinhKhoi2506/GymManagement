import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/content_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/content_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final contentController = Provider.of<ContentController>(context);
    final authController = Provider.of<AuthController>(context);

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
                        _buildHeader(context, contentController, authController),
                        const SizedBox(height: 32),
                        _buildContentGrid(contentController, authController),
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

  Widget _buildHeader(BuildContext context, ContentController controller, AuthController auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quản lý nội dung", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            Text("Quản lý bài viết, tin tức và danh mục hiển thị trên App", style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showContentDialog(context, controller, auth),
          icon: const Icon(Icons.post_add),
          label: const Text("Viết bài mới"),
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

  Widget _buildContentGrid(ContentController controller, AuthController auth) {
    if (controller.contents.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(100.0),
        child: Text("Chưa có nội dung nào được đăng."),
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.contents.length,
      itemBuilder: (context, index) {
        final content = controller.contents[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey[200],
                child: content.imageUrl != null 
                  ? Image.network(content.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content.category.toUpperCase(), style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(content.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(content.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showContentDialog(context, controller, auth, content: content)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => controller.deleteContent(content.id)),
                            Switch(
                              value: content.isPublished,
                              activeColor: Colors.green,
                              onChanged: (val) => controller.togglePublish(content.id, val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContentDialog(BuildContext context, ContentController controller, AuthController auth, {ContentModel? content}) {
    final titleController = TextEditingController(text: content?.title);
    final bodyController = TextEditingController(text: content?.body);
    String category = content?.category ?? 'Tin tức';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content == null ? "Viết bài mới" : "Chỉnh sửa bài viết"),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tiêu đề")),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: "Danh mục"),
                  items: ['Tin tức', 'Khuyến mãi', 'Kiến thức', 'Sự kiện'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => category = val!,
                ),
                const SizedBox(height: 16),
                TextField(controller: bodyController, maxLines: 10, decoration: const InputDecoration(labelText: "Nội dung bài viết", alignLabelWithHint: true, border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && bodyController.text.isNotEmpty) {
                if (content == null) {
                  await controller.addContent(ContentModel(
                    id: '',
                    title: titleController.text,
                    body: bodyController.text,
                    category: category,
                    author: auth.currentUser?.fullName ?? 'Admin',
                    createdAt: DateTime.now(),
                  ));
                } else {
                  await controller.updateContent(content.copyWith(
                    title: titleController.text,
                    body: bodyController.text,
                    category: category,
                  ));
                }
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            child: Text(content == null ? "Đăng bài" : "Cập nhật"),
          ),
        ],
      ),
    );
  }
}
