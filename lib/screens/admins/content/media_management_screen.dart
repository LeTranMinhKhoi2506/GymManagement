import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/media_controller.dart';
import '../../../data/models/media_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class MediaManagementScreen extends StatefulWidget {
  const MediaManagementScreen({super.key});

  @override
  State<MediaManagementScreen> createState() => _MediaManagementScreenState();
}

class _MediaManagementScreenState extends State<MediaManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaController = Provider.of<MediaController>(context);

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
                        _buildHeader(context, mediaController),
                        const SizedBox(height: 32),
                        _buildMediaGrid(mediaController),
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

  Widget _buildHeader(BuildContext context, MediaController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thư viện Media",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
            Text("Quản lý hình ảnh và tệp tin hệ thống", style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _pickAndUploadFile(controller),
          icon: const Icon(Icons.upload_file),
          label: const Text("Tải lên tệp mới"),
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

  Widget _buildMediaGrid(MediaController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.mediaList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(100.0),
          child: Text("Thư viện trống. Hãy tải lên tệp đầu tiên!"),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.mediaList.length,
      itemBuilder: (context, index) {
        final media = controller.mediaList[index];
        return _buildMediaCard(media, controller);
      },
    );
  }

  Widget _buildMediaCard(MediaModel media, MediaController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: media.type == 'image'
                  ? Image.network(media.url, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)))
                  : const Center(child: Icon(Icons.insert_drive_file, size: 40, color: Colors.blueGrey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(media.size / 1024).toStringAsFixed(1)} KB",
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      onPressed: () => controller.deleteMedia(media.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  Future<void> _pickAndUploadFile(MediaController controller) async {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    
    final stockImages = [
      {
        "name": "kinetic_gym_main.jpg",
        "url": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800"
      },
      {
        "name": "workout_motivation.jpg",
        "url": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800"
      },
      {
        "name": "yoga_meditation.jpg",
        "url": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800"
      },
      {
        "name": "whey_supplement.jpg",
        "url": "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=800"
      },
      {
        "name": "cardio_bikes.jpg",
        "url": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800"
      },
      {
        "name": "trainer_portrait.jpg",
        "url": "https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=800"
      }
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tải lên tài sản Media mới"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cách 1: Chọn từ ảnh Gym mẫu chất lượng cao", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A192F))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stockImages.length,
                      itemBuilder: (context, index) {
                        final item = stockImages[index];
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              urlController.text = item["url"]!;
                              nameController.text = item["name"]!;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: urlController.text == item["url"] ? const Color(0xFFFF6B35) : Colors.grey.shade300, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(item["url"]!, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Cách 2: Nhập liên kết ảnh & tên tệp tùy chỉnh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A192F))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: "Đường dẫn ảnh (URL)",
                      border: OutlineInputBorder(),
                      hintText: "https://images.unsplash.com/...",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên tệp tin (fileName)",
                      border: OutlineInputBorder(),
                      hintText: "vi_du_anh.jpg",
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
                if (urlController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  await controller.uploadMedia(
                    url: urlController.text.trim(),
                    fileName: nameController.text.trim(),
                    type: 'image',
                    size: 100000 + (urlController.text.length * 123), // Giả lập kích thước file
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: const Text("Tải lên ngay"),
            ),
          ],
        ),
      ),
    );
  }
}
