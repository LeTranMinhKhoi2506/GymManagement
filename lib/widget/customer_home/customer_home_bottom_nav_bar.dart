import 'package:flutter/material.dart';

class CustomerHomeBottomNavBar extends StatelessWidget {
  const CustomerHomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_CustomerBottomNavItemData> _items = [
    _CustomerBottomNavItemData(label: 'HOME', icon: Icons.home_rounded),
    _CustomerBottomNavItemData(
      label: 'TRAINERS',
      icon: Icons.sports_gymnastics_rounded,
    ),
    _CustomerBottomNavItemData(label: 'WORKOUTS', icon: Icons.bolt_rounded),
    _CustomerBottomNavItemData(label: 'PROFILE', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF202020)),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;
            return Expanded(
              child: _CustomerBottomBarItem(
                item: item,
                selected: selected,
                onTap: () => onChanged(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CustomerBottomBarItem extends StatelessWidget {
  const _CustomerBottomBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _CustomerBottomNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFE9D84D);
    final normalColor = const Color(0xFF8E8E8E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected ? const Color(0xFF212121) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 19,
                  color: selected ? activeColor : normalColor,
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? activeColor : normalColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
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

class _CustomerBottomNavItemData {
  const _CustomerBottomNavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
