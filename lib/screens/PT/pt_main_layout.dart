import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/nav_bar/gym_bottom_nav_bar.dart';

class PtMainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget child;

  const PtMainLayout({
    super.key,
    required this.navigationShell,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: child,
      bottomNavigationBar: GymBottomNavBar(
        navigationShell: navigationShell,
        selectedItemColor: const Color(0xFFD0FD3E),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "LỊCH DẠY"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "HỌC VIÊN"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "TÀI KHOẢN"),
        ],
      ),
    );
  }
}
