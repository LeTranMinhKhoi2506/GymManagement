import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/route/routes.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/social_post_model.dart';
import '../../provider/home_provider.dart';
import 'home_action_chip.dart';
import 'home_comment_tile.dart';
import 'home_exercise_list.dart';
import 'home_latest_comment_hint.dart';
import 'home_post_media_gallery.dart';
import 'home_social_feed_theme.dart';

class HomePostCard extends StatelessWidget {
  const HomePostCard({super.key, required this.post});

  final SocialPostModel post;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: HomeSocialFeedTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: post.authorId.startsWith('admin')
                    ? null
                    : () {
                        context.push('${Routes.userProfile}/${post.authorId}');
                      },
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: HomeSocialFeedTheme.cardAlt,
                  backgroundImage: (post.authorAvatarUrl != null &&
                          post.authorAvatarUrl!.trim().isNotEmpty)
                      ? NetworkImage(post.authorAvatarUrl!)
                      : null,
                  child: (post.authorAvatarUrl == null ||
                          post.authorAvatarUrl!.trim().isEmpty)
                      ? Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: post.authorId.startsWith('admin')
                      ? null
                      : () {
                          context.push('${Routes.userProfile}/${post.authorId}');
                        },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        post.timeLabel.isNotEmpty
                            ? post.timeLabel
                            : homeRelativeTime(post.createdAt),
                        style: const TextStyle(
                          color: HomeSocialFeedTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!post.authorId.startsWith('admin'))
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8B63),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    '+ Follow',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (post.caption.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              post.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (post.exercises.isNotEmpty) ...[
            const SizedBox(height: 14),
            HomeExerciseList(exercises: post.exercises),
          ],
          if (post.mediaItems.isNotEmpty) ...[
            const SizedBox(height: 14),
            HomePostMediaGallery(mediaItems: post.mediaItems),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              HomeActionChip(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: post.likeCount.toString(),
                active: post.isLiked,
                onTap: () => provider.toggleLike(post.id),
              ),
              const SizedBox(width: 16),
              HomeActionChip(
                icon: Icons.mode_comment_outlined,
                label: post.commentCount.toString(),
                onTap: () => _openCommentsSheet(context, post),
              ),
              const SizedBox(width: 16),
              const HomeActionChip(
                icon: Icons.share_outlined,
                label: '',
              ),
            ],
          ),
          if (post.commentCount > 0) ...[
            const SizedBox(height: 12),
            HomeLatestCommentHint(postId: post.id),
          ],
        ],
      ),
    );
  }

  Future<void> _openCommentsSheet(
    BuildContext context,
    SocialPostModel post,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeCommentsSheet(post: post),
    );
  }
}

class HomeCommentsSheet extends StatefulWidget {
  const HomeCommentsSheet({super.key, required this.post});

  final SocialPostModel post;

  @override
  State<HomeCommentsSheet> createState() => _HomeCommentsSheetState();
}

class _HomeCommentsSheetState extends State<HomeCommentsSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111317),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.post.commentCount.toString(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: StreamBuilder<List<CommentModel>>(
                  stream: provider.watchComments(widget.post.id),
                  builder: (context, snapshot) {
                    final comments = snapshot.data ?? const <CommentModel>[];
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        comments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chua co binh luan nao. Hay la nguoi dau tien!',
                          style: TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return HomeCommentTile(comment: comment);
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 3,
                          minLines: 1,
                          cursorColor: HomeSocialFeedTheme.accent,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Viet binh luan...',
                            hintStyle: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1B1E24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: HomeSocialFeedTheme.accent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () async {
                            final error = await provider.addComment(
                              postId: widget.post.id,
                              content: _controller.text,
                            );
                            if (!context.mounted) return;
                            if (error != null) {
                              showDialog<void>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  backgroundColor: const Color(0xFF1B1E24),
                                  title: const Text(
                                    'Thông báo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    error,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text(
                                        'Đồng ý',
                                        style: TextStyle(
                                          color: HomeSocialFeedTheme.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            _controller.clear();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.send_rounded, color: Colors.black),
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
  }
}


