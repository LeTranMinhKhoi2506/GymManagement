import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/content_model.dart';

class NewsDetailDialog extends StatelessWidget {
  final ContentModel post;

  const NewsDetailDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFE9D84D);

    return Dialog(
      backgroundColor: const Color(0xFF0F0F0F),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF202020)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: const Color(0xFF1A1A1A),
                    child: post.imageUrl != null
                        ? Image.network(post.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
                        : const Center(child: Icon(Icons.article_outlined, size: 50, color: Colors.grey)),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              // Body Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              post.category.toUpperCase(),
                              style: TextStyle(color: activeColor, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            "Đăng bởi: ${post.author}",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF202020), height: 32),
                      Text(
                        post.body,
                        style: const TextStyle(
                          color: Color(0xFFD8D8D8),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
