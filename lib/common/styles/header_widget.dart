import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chào mừng trở lại, Admin",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("Tổng quan hệ thống",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          _headerAction(Icons.search),
          const SizedBox(width: 16),
          _headerAction(Icons.notifications_none),
          const SizedBox(width: 24),
          const VerticalDivider(indent: 20, endIndent: 20),
          const SizedBox(width: 24),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Quản trị viên",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Cấp cao",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF0A192F),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 20, color: Colors.grey[700]),
    );
  }
}
