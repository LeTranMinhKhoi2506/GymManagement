import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';

class SummaryCards extends StatelessWidget {
  final AdminController controller;

  const SummaryCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: StreamBuilder<int>(
          stream: controller.totalMembersStream,
          builder: (context, snapshot) => _statCard(
              "Tổng hội viên",
              (snapshot.data ?? 0).toString(),
              Icons.group,
              Colors.blue,
              "+12% so với tháng trước"),
        )),
        const SizedBox(width: 24),
        Expanded(
            child: StreamBuilder<int>(
          stream: controller.staffCountStream,
          builder: (context, snapshot) => _statCard(
              "Nhân viên",
              "${snapshot.data ?? 0}/28",
              Icons.badge,
              Colors.orange,
              "Sẵn sàng hoạt động"),
        )),
        const SizedBox(width: 24),
        Expanded(
            child: StreamBuilder<double>(
          stream: controller.todayRevenueStream,
          builder: (context, snapshot) => _statCard(
              "Doanh thu hôm nay",
              "\$${snapshot.data ?? 0}",
              Icons.payments,
              Colors.green,
              "Theo thời gian thực",
              isDark: true),
        )),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color,
      String subtitle,
      {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A192F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:  0.04),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: color, size: 28),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          Text(value,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: isDark ? Colors.grey : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(subtitle,
              style: TextStyle(
                  color: isDark ? Colors.greenAccent : color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
