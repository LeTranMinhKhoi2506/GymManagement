import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/nav_bar/gym_bottom_nav_bar.dart';

class ReceptionistMainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget child;

  const ReceptionistMainLayout({
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
        selectedItemColor: const Color(0xFFFF6B35),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: "CHECK-IN"),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: "MUA BÁN"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: "HỖ TRỢ"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: "THIẾT BỊ"),
        ],
      ),
    );
  }
}
