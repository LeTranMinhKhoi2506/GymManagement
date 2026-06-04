import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/home_provider.dart';

class HomeFeedHeader extends StatelessWidget {
  const HomeFeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<HomeProvider, HomeFeedMode>((p) => p.feedMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _FeedModeDropdown(mode: mode),
            const Spacer(),
            _HeaderIconButton(icon: Icons.search_rounded, onTap: () {}),
            const SizedBox(width: 10),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedModeDropdown extends StatelessWidget {
  const _FeedModeDropdown({required this.mode});

  final HomeFeedMode mode;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    final label = mode == HomeFeedMode.following ? 'Home (Following)' : 'Discover';

    return PopupMenuButton<HomeFeedMode>(
      onSelected: provider.changeFeedMode,
      color: const Color(0xFF1A1B20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      offset: const Offset(0, 48),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: HomeFeedMode.following,
          child: Row(
            children: [
              const Icon(Icons.home_outlined, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Home (Following)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (mode == HomeFeedMode.following)
                const Icon(Icons.check_rounded, color: Color(0xFF4DA3FF)),
            ],
          ),
        ),
        PopupMenuItem(
          value: HomeFeedMode.discover,
          child: Row(
            children: [
              const Icon(Icons.language_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Discover',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (mode == HomeFeedMode.discover)
                const Icon(Icons.check_rounded, color: Color(0xFF4DA3FF)),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
