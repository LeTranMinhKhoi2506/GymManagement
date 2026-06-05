import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/social_post_model.dart';
import '../../provider/home_provider.dart';
import '../../widget/home_social_feed/home_feed_create_fab.dart';
import '../../widget/home_social_feed/home_feed_empty_state.dart';
import '../../widget/home_social_feed/home_feed_header.dart';
import '../../widget/home_social_feed/home_post_card.dart';
import '../../widget/home_social_feed/home_social_feed_theme.dart';
import '../customer_home/social_feed/create_post_screen.dart';

class HomeScreenCustomer extends StatelessWidget {
  const HomeScreenCustomer({
    super.key,
    this.showCreateFab = false,
    this.bottomPadding = 120,
  });

  final bool showCreateFab;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(),
      child: HomeScreenCustomerContent(
        showCreateFab: showCreateFab,
        bottomPadding: bottomPadding,
      ),
    );
  }
}

class HomeScreenCustomerContent extends StatelessWidget {
  const HomeScreenCustomerContent({
    super.key,
    required this.showCreateFab,
    required this.bottomPadding,
  });

  final bool showCreateFab;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final loading = context.select<HomeProvider, bool>((p) => p.loading);
    final errorMessage = context.select<HomeProvider, String?>((p) => p.errorMessage);
    final posts = context.select<HomeProvider, List<SocialPostModel>>((p) => p.posts);

    return Scaffold(
      backgroundColor: HomeSocialFeedTheme.bg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                  sliver: SliverToBoxAdapter(child: HomeFeedHeader()),
                ),
                if (loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: HomeSocialFeedTheme.accent,
                      ),
                    ),
                  )
                else if (errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeFeedEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Khong the tai feed',
                      subtitle: errorMessage,
                    ),
                  )
                else if (posts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeFeedEmptyState(
                      icon: Icons.dynamic_feed_rounded,
                      title: 'Chua co bai viet nao',
                      subtitle:
                          'Hay bam dau + o goc duoi phai de tao bai viet dau tien.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding),
                    sliver: SliverList.separated(
                      itemCount: posts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return HomePostCard(post: post);
                      },
                    ),
                  ),
              ],
            ),
            if (showCreateFab)
              Positioned(
                right: 14,
                bottom: 12,
                child: HomeFeedCreateFab(
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
              ),
          ],
        ),
      ),
    );
  }
}
