import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/content_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/media_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/content_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            const SidebarWidget(),
            Expanded(
              child: Column(
                children: [
                  const HeaderWidget(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, contentController, authController),
                          const SizedBox(height: 24),
                          const TabBar(
                            labelColor: Color(0xFFFF6B35),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(0xFFFF6B35),
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.article_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text("Bài viết hệ thống (Admin)"),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.forum_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text("Bài đăng mạng xã hội (PT)"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Tab 1: System Articles
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildContentGrid(contentController, authController),
                                    ],
                                  ),
                                ),
                                // Tab 2: PT Social Posts
                                _buildPTPostsList(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                              activeThumbColor: Colors.green,
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
    String? selectedImageUrl = content?.imageUrl;

    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final contentCategories = categoryController.categories
        .where((cat) => cat.type == 'Content')
        .map((cat) => cat.name)
        .toList();
    if (contentCategories.isEmpty) {
      contentCategories.addAll(['Tin tức', 'Khuyến mãi', 'Kiến thức', 'Sự kiện']);
    }
    if (!contentCategories.contains(category)) {
      category = contentCategories.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(content == null ? "Viết bài mới" : "Chỉnh sửa bài viết"),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tiêu đề")),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: "Danh mục"),
                    items: contentCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => category = val!,
                  ),
                  const SizedBox(height: 16),
                  const Text("Ảnh bìa bài viết", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: selectedImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(selectedImageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                              )
                            : const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showMediaPickerDialog(context, (url) {
                          setDialogState(() {
                            selectedImageUrl = url;
                          });
                        }),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text("Chọn từ thư viện"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A192F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      if (selectedImageUrl != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedImageUrl = null;
                            });
                          },
                          child: const Text("Xóa ảnh", style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bodyController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: "Nội dung bài viết",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
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
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                      imageUrl: selectedImageUrl,
                      category: category,
                      author: auth.currentUser?.fullName ?? 'Admin',
                      createdAt: DateTime.now(),
                      isPublished: true,
                    ));
                  } else {
                    await controller.updateContent(content.copyWith(
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                      imageUrl: selectedImageUrl,
                      category: category,
                    ));
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: Text(content == null ? "Đăng bài" : "Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerDialog(BuildContext context, Function(String) onSelect) {
    final mediaController = Provider.of<MediaController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chọn ảnh bìa từ thư viện Media"),
        content: SizedBox(
          width: 550,
          height: 380,
          child: mediaController.mediaList.isEmpty
              ? const Center(child: Text("Thư viện Media trống. Hãy sinh dữ liệu mẫu trong Công cụ Dev hoặc tải lên trong Thư viện Media."))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: mediaController.mediaList.length,
                  itemBuilder: (context, index) {
                    final media = mediaController.mediaList[index];
                    return GestureDetector(
                      onTap: () {
                        onSelect(media.url);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(media.url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image))),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }

  Widget _buildPTPostsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text("Chưa có bài đăng nào từ PT.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final postId = doc.id;
            final authorName = data['authorName'] ?? 'Huấn luyện viên';
            final authorAvatarUrl = data['authorAvatarUrl'];
            final caption = data['caption'] ?? '';
            final likeCount = data['likeCount'] ?? 0;
            final commentCount = data['commentCount'] ?? 0;
            
            DateTime? createdAt;
            if (data['createdAt'] != null) {
              if (data['createdAt'] is Timestamp) {
                createdAt = (data['createdAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is String) {
                createdAt = DateTime.tryParse(data['createdAt']);
              }
            }

            final mediaItems = data['mediaItems'] as List<dynamic>? ?? [];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (authorAvatarUrl != null && authorAvatarUrl.toString().isNotEmpty)
                        ? NetworkImage(authorAvatarUrl.toString())
                        : null,
                    child: (authorAvatarUrl == null || authorAvatarUrl.toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Name & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A192F)),
                            ),
                            if (createdAt != null)
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Caption
                        Text(
                          caption,
                          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        
                        // Media preview
                        if (mediaItems.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: mediaItems.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, mIdx) {
                                final media = mediaItems[mIdx];
                                final path = media['path'] ?? '';
                                final isImage = media['type'] == 'image' || media['type'] == 0;
                                
                                return Container(
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isImage && path.isNotEmpty
                                        ? Image.network(path, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
                                        : const Center(child: Icon(Icons.play_circle_fill, size: 36, color: Colors.grey)),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (mediaItems.isNotEmpty) const SizedBox(height: 16),

                        // Stats (Likes, Comments)
                        Row(
                          children: [
                            Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("$likeCount lượt thích", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(width: 20),
                            Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("$commentCount bình luận", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Actions (Delete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: "Xóa bài đăng",
                    onPressed: () => _confirmDeletePTPost(context, postId),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeletePTPost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa bài đăng mạng xã hội này của PT không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã xóa bài đăng của PT thành công"),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}
