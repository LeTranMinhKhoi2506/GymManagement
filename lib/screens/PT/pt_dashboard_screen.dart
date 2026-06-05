import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../app/route/routes.dart';
import '../../data/models/social_post_model.dart';
import '../../provider/home_provider.dart';
import '../customer_home/social_feed/create_post_screen.dart';
import '../../widget/home_social_feed/home_post_card.dart';

class PtDashboardScreen extends StatefulWidget {
  const PtDashboardScreen({super.key});

  @override
  State<PtDashboardScreen> createState() => _PtDashboardScreenState();
}

class _PtDashboardScreenState extends State<PtDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(),
      child: const PtSocialFeedContent(),
    );
  }
}

class PtSocialFeedContent extends StatefulWidget {
  const PtSocialFeedContent({super.key});

  @override
  State<PtSocialFeedContent> createState() => _PtSocialFeedContentState();
}

class _PtSocialFeedContentState extends State<PtSocialFeedContent> {
  bool _isUploadingAvatar = false;

  void _confirmDeletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text(
          "XÓA BÀI VIẾT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn xóa bài viết này không? Bài viết sẽ không còn xuất hiện trên bảng tin của học viên.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "HỦY",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã xóa bài viết thành công!"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("XÓA", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAvatar(BuildContext context, String ptId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty || result.files.first.path == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final filePath = result.files.first.path!;
      final file = File(filePath);

      final fileName = p.basename(filePath);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child(ptId)
          .child(fileName);

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
      }

      await FirebaseFirestore.instance.collection('users').doc(ptId).update({
        'avatarUrl': downloadUrl,
        'photoUrl': downloadUrl,
        'profileImageUrl': downloadUrl,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật ảnh đại diện thành công!"),
            backgroundColor: Color(0xFFD0FD3E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi cập nhật ảnh đại diện: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ptUser = FirebaseAuth.instance.currentUser;
    final String ptId = ptUser?.uid ?? 'anonymous';
    final String ptName = ptUser?.displayName ?? 'Huấn luyện viên';
    final String? avatarUrl = ptUser?.photoURL;

    final loading = context.select<HomeProvider, bool>((p) => p.loading);
    final posts = context.select<HomeProvider, List<SocialPostModel>>((p) => p.posts);
    final myPosts = posts.where((p) => p.authorId == ptId).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white70, size: 18)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "KINETIC",
                          style: TextStyle(
                            color: Color(0xFFD0FD3E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
            
            // Welcome Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                        children: [
                          const TextSpan(text: "Bảng tin,\n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ptName, style: const TextStyle(color: Color(0xFFD0FD3E))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Cập nhật các bài viết tương tác, chia sẻ kiến thức tập luyện với các học viên.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Prompt Card for Creating Posts
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingAvatar ? null : () => _updateAvatar(context, ptId),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF2C2F36),
                              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty && !_isUploadingAvatar) ? NetworkImage(avatarUrl) : null,
                              child: (avatarUrl == null || _isUploadingAvatar)
                                  ? _isUploadingAvatar
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(color: Color(0xFFD0FD3E), strokeWidth: 1.5),
                                        )
                                      : const Icon(Icons.person, color: Colors.white70, size: 20)
                                  : null,
                            ),
                            if (!_isUploadingAvatar)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD0FD3E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final provider = context.read<HomeProvider>();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: provider,
                                  child: const CreatePostScreen(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              "Chia sẻ kinh nghiệm tập luyện của bạn...",
                              style: TextStyle(color: Colors.white30, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFFD0FD3E)),
                        onPressed: () {
                          final provider = context.read<HomeProvider>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: provider,
                                child: const CreatePostScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Title Section "BÀI VIẾT CỦA BẠN"
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "BÀI VIẾT CỦA BẠN",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    Text(
                      "${myPosts.length} bài viết",
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Feed list
            if (loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD0FD3E)),
                ),
              )
            else if (myPosts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "Bạn chưa đăng bài viết nào.\nHãy chia sẻ bài tập hoặc kiến thức đầu tiên!",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList.separated(
                  itemCount: myPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = myPosts[index];
                    return Stack(
                      children: [
                        HomePostCard(post: post),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () => _confirmDeletePost(context, post.id),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'note': return Icons.edit_note;
      case 'session': return Icons.check_circle_outline;
      case 'booking': return Icons.assignment_turned_in_outlined;
      default: return Icons.notifications_none;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'note': return const Color(0xFFD0FD3E);
      case 'session': return Colors.orangeAccent;
      case 'booking': return Colors.yellowAccent;
      default: return Colors.white;
    }
  }

}

// Widget Dialog quét mã QR Chấm công với hiệu ứng quét camera cực chuyên nghiệp và mượt mà
class QRScannerDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onSuccess;

  const QRScannerDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSuccess,
  });

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _lineAnimationController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Giả lập quét QR thành công sau 2 giây
    Timer(const Duration(seconds: 2), () async {
      if (mounted) {
        setState(() {
          _isSuccess = true;
        });
        _lineAnimationController.stop();
        // Đóng Dialog sau 1 giây hiển thị thành công, sau đó chạy onSuccess
        Timer(const Duration(seconds: 1), () async {
          if (mounted) {
            Navigator.pop(context); // Đóng QRScannerDialog trước
            await widget.onSuccess(); // Chạy callback để cập nhật và hiện kết quả
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            
            // Khung hình giả lập máy quét camera
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Giả lập background Camera
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      height: double.infinity,
                      child: Opacity(
                        opacity: 0.3,
                        child: Center(
                          child: Icon(
                            _isSuccess ? Icons.qr_code_2 : Icons.camera_alt_outlined, 
                            color: Colors.white30, 
                            size: 150
                          ),
                        ),
                      ),
                    ),
                    
                    // Khung quét QR phát sáng
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isSuccess ? Colors.greenAccent : const Color(0xFFD0FD3E), 
                            width: 2
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // Góc quét QR phong cách khoa học viễn tưởng
                    ..._buildCornerBorders(),

                    // Dòng quét chuyển động quét
                    if (!_isSuccess)
                      AnimatedBuilder(
                        animation: _lineAnimationController,
                        builder: (context, child) {
                          // Chuyển động từ 10% đến 90% chiều cao của khung
                          double offset = 220 * _lineAnimationController.value;
                          return Positioned(
                            top: (MediaQuery.of(context).size.width - 50 - 220) / 2 + offset - 10, // Cân chỉnh dòng quét tương đối
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 220,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD0FD3E),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD0FD3E).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                ),
                              ),
                            ),
                          );
                        }
                      ),

                    // Hiển thị trạng thái thành công
                    if (_isSuccess)
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check, 
                            color: Colors.black, 
                            size: 45,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Nút hủy/Đóng
            if (!_isSuccess)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text("HỦY BỎ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerBorders() {
    const double length = 20;
    const double thickness = 4;
    final color = _isSuccess ? Colors.greenAccent : const Color(0xFFD0FD3E);

    return [
      // Top Left Corner
      Positioned(
        top: 25,
        left: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        top: 25,
        left: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Top Right Corner
      Positioned(
        top: 25,
        right: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        top: 25,
        right: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Bottom Left Corner
      Positioned(
        bottom: 25,
        left: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        bottom: 25,
        left: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Bottom Right Corner
      Positioned(
        bottom: 25,
        right: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        bottom: 25,
        right: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
    ];
  }
}
