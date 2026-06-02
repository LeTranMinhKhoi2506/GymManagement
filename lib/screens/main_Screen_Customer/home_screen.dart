import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/social_post_model.dart';
import '../../data/models/workout_exercise_model.dart';
import '../../provider/home_provider.dart';
import '../customer_home/social_feed/create_post_screen.dart';
import '../../widget/home_Customer/bottom_nav_bar.dart';

class HomeScreenCustomer extends StatelessWidget {
  const HomeScreenCustomer({super.key});

  static const Color bgColor = Color(0xFF080808);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeScreenScaffold(),
    );
  }
}

class _HomeScreenScaffold extends StatelessWidget {
  const _HomeScreenScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: HomeScreenCustomer.bgColor,
      body: HomeScreenCustomerContent(showBottomNav: true, showCreateFab: true),
    );
  }
}

class HomeScreenCustomerContent extends StatelessWidget {
  const HomeScreenCustomerContent({
    super.key,
    this.showBottomNav = false,
    this.showCreateFab = false,
    this.bottomPadding = 24,
  });

  final bool showBottomNav;
  final bool showCreateFab;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final scrollBottomPadding = showBottomNav ? 110.0 : bottomPadding;
    final loading = context.select<HomeProvider, bool>(
      (provider) => provider.loading,
    );
    final errorMessage = context.select<HomeProvider, String?>(
      (provider) => provider.errorMessage,
    );
    final posts = context.select<HomeProvider, List<SocialPostModel>>(
      (provider) => provider.posts,
    );

    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _SocialTopBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _FeedMessage(
                      icon: Icons.error_outline,
                      message: errorMessage,
                    ),
                  ),
                ),
              if (loading && posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFECEBC4)),
                  ),
                )
              else if (!loading && posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: Text(
                        'Chua co bai viet nao.\nHay dang bai dau tien cua ban.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, scrollBottomPadding),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) =>
                        _PostCard(post: posts[index]),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemCount: posts.length,
                  ),
                ),
            ],
          ),
          if (showCreateFab) const _CreatePostFab(),
          if (showBottomNav) const BottomNavBar(),
        ],
      ),
    );
  }
}

class _CreatePostFab extends StatelessWidget {
  const _CreatePostFab();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 14,
      bottom: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final homeProvider = context.read<HomeProvider>();
            homeProvider.resetDraft();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider<HomeProvider>.value(
                  value: homeProvider,
                  child: const CreatePostScreen(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8E63),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FF8E63),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }
}

class _SocialTopBar extends StatelessWidget {
  const _SocialTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text(
            'Discover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42 / 1.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white70),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
          ),
          const Text(
            'KINETIC',
            style: TextStyle(
              color: Color(0xFFECEBC4),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15171B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final SocialPostModel post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF1D2E44),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        post.timeLabel,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '+ Follow',
                    style: TextStyle(
                      color: Color(0xFFFF8E63),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Text(
              post.caption,
              style: const TextStyle(color: Colors.white70, height: 1.3),
            ),
          ),
          if (post.exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.exercises
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${item.sets} sets x ${item.reps} reps ${item.name}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _PostMediaGallery(post: post),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    try {
                      await context.read<HomeProvider>().toggleLike(post.id);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Khong the cap nhat like luc nay.'),
                          ),
                        );
                    }
                  },
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.redAccent : Colors.white70,
                  ),
                ),
                Text(
                  '${post.likes}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.comments}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.share_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMediaGallery extends StatelessWidget {
  const _PostMediaGallery({required this.post});

  final SocialPostModel post;

  @override
  Widget build(BuildContext context) {
    if (post.mediaItems.isEmpty) {
      return const SizedBox(height: 0);
    }

    if (post.mediaItems.length == 1) {
      return _MediaTile(item: post.mediaItems.first, height: 220);
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 180,
            child: _MediaTile(item: post.mediaItems[index], height: 220),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: post.mediaItems.length,
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.height});

  final SocialMediaModel item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isLocal = context.read<HomeProvider>().isLocalFile(item.path);
    if (item.type == SocialMediaType.video) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 44),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isLocal
          ? Image.file(
              File(item.path),
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              item.path,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }
}
