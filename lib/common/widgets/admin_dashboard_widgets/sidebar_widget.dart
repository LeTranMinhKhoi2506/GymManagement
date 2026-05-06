import 'package:flutter/material.dart';
import '../../../app/route/Routes.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      width: 250,
      color: const Color(0xFF0A192F),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, color: Color(0xFFFF6B35), size: 30),
                SizedBox(width: 12),
                Text("GYM ADMIN",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
          _sidebarItem(context, Icons.dashboard, "Bảng điều khiển", Routes.adminDashboard, currentRoute == Routes.adminDashboard),
          _sidebarItem(context, Icons.badge, "Nhân sự", Routes.personnelManagement, currentRoute == Routes.personnelManagement),
          _sidebarItem(context, Icons.calendar_month, "Lịch làm việc", Routes.scheduleManagement, currentRoute == Routes.scheduleManagement),
          _sidebarItem(context, Icons.group, "Khách hàng", Routes.customerManagement, currentRoute == Routes.customerManagement),
          _sidebarItem(context, Icons.payments, "Tài chính", "/finance", false),
          _sidebarItem(context, Icons.build, "Thiết bị", "/equipment", false),
          _sidebarItem(context, Icons.settings, "Cài đặt", "/settings", false),
          const Spacer(),
          _sidebarItem(context, Icons.logout, "Đăng xuất", Routes.login, false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B35).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.blueGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
