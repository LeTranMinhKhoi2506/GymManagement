import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/route/routes.dart';

class HomeFeedHeader extends StatelessWidget {
  const HomeFeedHeader({
    super.key,
    this.onSearchTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final searchTap = onSearchTap ?? () => context.push(Routes.socialSearch);
    final notificationsTap =
        onNotificationsTap ?? () => context.push(Routes.socialNotifications);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Discover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1C21),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFD7D9DE),
                  size: 20,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: searchTap,
                icon: const Icon(Icons.search_rounded),
                color: Colors.white,
                iconSize: 29,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: notificationsTap,
                icon: const Icon(Icons.notifications_none_rounded),
                color: Colors.white,
                iconSize: 29,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A8EF7),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '+ Follow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
