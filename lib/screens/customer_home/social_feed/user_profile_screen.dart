import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/social_post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../provider/home_provider.dart';
import '../../../widget/home_social_feed/home_post_card.dart';
import '../../../widget/home_social_feed/home_social_feed_theme.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();

    return Scaffold(
      backgroundColor: HomeSocialFeedTheme.bg,
      appBar: AppBar(
        backgroundColor: HomeSocialFeedTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'TRANG CÁ NHÂN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: provider.getUserById(userId),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: HomeSocialFeedTheme.accent,
              ),
            );
          }

          final user = userSnapshot.data;
          final displayName = user?.fullName ?? 'Thành viên';
          final email = user?.email ?? '';
          final position = user?.position ?? (user?.role == 'admin' ? 'Quản trị viên' : 'Hội viên');

          return CustomScrollView(
            slivers: [
              // PROFILE HEADER CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HomeSocialFeedTheme.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: HomeSocialFeedTheme.cardAlt,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF20242B),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            position.toUpperCase(),
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            email,
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber!,
                            style: const TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // SECTION POSTS LABEL
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'BÀI ĐĂNG GẦN ĐÂY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // LIST OF POSTS
              StreamBuilder<List<SocialPostModel>>(
                stream: provider.watchPostsByUserId(userId),
                builder: (context, postsSnapshot) {
                  if (postsSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: HomeSocialFeedTheme.accent,
                          ),
                        ),
                      ),
                    );
                  }

                  final posts = postsSnapshot.data ?? const <SocialPostModel>[];
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            'Chưa có bài đăng nào.',
                            style: TextStyle(
                              color: HomeSocialFeedTheme.muted,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: HomePostCard(post: posts[index]),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
