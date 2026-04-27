import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/home_provider.dart';
import '../../widget/home_Customer/bottom_nav_bar.dart';
import '../../widget/home_Customer/header_section.dart';
import '../../widget/home_Customer/health_stats_row.dart';
import '../../widget/home_Customer/next_session_card.dart';
import '../../widget/home_Customer/qr_check_in_card.dart';
import '../../widget/home_Customer/quick_actions_section.dart';
import '../../widget/home_Customer/search_box.dart';
import '../../widget/home_Customer/session_carousel.dart';

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
      body: HomeScreenCustomerContent(showBottomNav: true),
    );
  }
}

class HomeScreenCustomerContent extends StatelessWidget {
  const HomeScreenCustomerContent({
    super.key,
    this.showBottomNav = false,
    this.bottomPadding = 24,
  });

  final bool showBottomNav;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final scrollBottomPadding = showBottomNav ? 110.0 : bottomPadding;

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, scrollBottomPadding),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderSection(),
                SizedBox(height: 32),
                SearchBox(),
                SizedBox(height: 32),
                SessionCarousel(),
                SizedBox(height: 32),
                QrCheckInCard(),
                SizedBox(height: 32),
                NextSessionCard(),
                SizedBox(height: 22),
                HealthStatsRow(),
                SizedBox(height: 34),
                QuickActionsHeader(),
                SizedBox(height: 20),
                QuickActionsRow(),
              ],
            ),
          ),
          if (showBottomNav) const BottomNavBar(),
        ],
      ),
    );
  }
}


