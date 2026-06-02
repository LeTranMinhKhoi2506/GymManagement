import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/content_controller.dart';
import '../../data/models/content_model.dart';
import 'news_detail_dialog.dart';

class CustomerNewsSection extends StatelessWidget {
  const CustomerNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = Provider.of<ContentController>(context);
    final publishedPosts = contentController.contents.where((post) => post.isPublished).toList();

    if (publishedPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TIN TỨC & KHUYẾN MÃI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: publishedPosts.length,
            itemBuilder: (context, index) {
              final post = publishedPosts[index];
              return _buildNewsCard(context, post);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, ContentModel post) {
    final cardBgColor = const Color(0xFF111111);
    final borderCol = const Color(0xFF202020);
    final activeColor = const Color(0xFFE9D84D);

    return GestureDetector(
      onTap: () => _showArticleDetails(context, post),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  color: const Color(0xFF1E1E1E),
                  width: double.infinity,
                  child: post.imageUrl != null
                      ? Image.network(post.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
                      : const Center(child: Icon(Icons.article_outlined, size: 40, color: Colors.grey)),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.category.toUpperCase(),
                        style: TextStyle(color: activeColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Bởi: ${post.author}",
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(post.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetails(BuildContext context, ContentModel post) {
    showDialog(
      context: context,
      builder: (context) => NewsDetailDialog(post: post),
    );
  }
}
