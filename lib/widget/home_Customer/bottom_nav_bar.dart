import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/home_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: const Row(
            children: [
              Expanded(child: BottomNavItem(icon: Icons.home, label: 'HOME', index: 0)),
              Expanded(child: BottomNavItem(icon: Icons.bolt, label: 'TRAINERS', index: 1)),
              Expanded(child: BottomNavItem(icon: Icons.whatshot, label: 'WORKOUTS', index: 2)),
              Expanded(child: BottomNavItem(icon: Icons.person, label: 'PROFILE', index: 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
  });

  final IconData icon;
  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<HomeProvider, bool>((p) => p.selectedIndex == index);

    return GestureDetector(
      onTap: () => context.read<HomeProvider>().changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isSelected ? 84 : 72,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF282828) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
              size: 27,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

