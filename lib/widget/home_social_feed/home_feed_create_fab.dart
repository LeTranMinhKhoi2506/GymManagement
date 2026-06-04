import 'package:flutter/material.dart';

import 'home_social_feed_theme.dart';

class HomeFeedCreateFab extends StatelessWidget {
  const HomeFeedCreateFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF202020),
      shape: const CircleBorder(),
      elevation: 8,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.add_rounded,
            color: HomeSocialFeedTheme.accent,
            size: 30,
          ),
        ),
      ),
    );
  }
}
