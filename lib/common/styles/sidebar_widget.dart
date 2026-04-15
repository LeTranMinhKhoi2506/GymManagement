import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          _sidebarItem(Icons.dashboard, "Bảng điều khiển", true),
          _sidebarItem(Icons.badge, "Nhân sự", false),
          _sidebarItem(Icons.group, "Khách hàng", false),
          _sidebarItem(Icons.payments, "Tài chính", false),
          _sidebarItem(Icons.event_note, "Lớp học", false),
          _sidebarItem(Icons.build, "Thiết bị", false),
          _sidebarItem(Icons.settings, "Cài đặt", false),
          const Spacer(),
          _sidebarItem(Icons.logout, "Đăng xuất", false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B35).withValues(alpha:  0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.blueGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
