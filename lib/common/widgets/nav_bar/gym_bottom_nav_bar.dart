import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GymBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<BottomNavigationBarItem> items;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const GymBottomNavBar({
    super.key,
    required this.navigationShell,
    required this.items,
    required this.selectedItemColor,
    this.unselectedItemColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        currentIndex: navigationShell.currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: items,
      ),
    );
  }
}
