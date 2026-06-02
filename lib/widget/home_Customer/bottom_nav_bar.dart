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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Expanded(child: BottomNavItem(icon: Icons.home, label: 'HOME', index: 0)),
                Expanded(child: BottomNavItem(icon: Icons.bolt, label: 'TRAIN', index: 1)),
                Expanded(child: BottomNavItem(icon: Icons.whatshot, label: 'WORK', index: 2)),
                Expanded(child: BottomNavItem(icon: Icons.storefront_rounded, label: 'SHOP', index: 3)),
              ],
            ),
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
    // Special styling for middle (index == 2): elevated circular button
    if (index == 2) {
      return GestureDetector(
        onTap: () => context.read<HomeProvider>().changeTab(index),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 52 : 46,
                height: isSelected ? 52 : 46,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [Color(0xFF3A3A3A), Color(0xFF282828)])
                      : null,
                  color: isSelected ? const Color(0xFF282828) : const Color(0xFF1A1A1A),
                  boxShadow: isSelected
                      ? const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3))]
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
                  size: isSelected ? 27 : 23,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.read<HomeProvider>().changeTab(index),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF212121) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFF1FFD0) : const Color(0xFF8A8A8A),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

