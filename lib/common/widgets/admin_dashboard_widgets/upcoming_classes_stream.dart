import 'package:flutter/material.dart';
import '../../../controllers/admin_controller.dart';

class UpcomingClassesStream extends StatelessWidget {
  final AdminController controller;

  const UpcomingClassesStream({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lớp học sắp tới",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.upcomingClassesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final classes = snapshot.data!;
              if (classes.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDEEEF)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Không có lớp học nào sắp tới",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Dữ liệu lớp học hiện tại đang trống. Bạn có thể vào mục Công cụ Dev để sinh/nạp dữ liệu mẫu lớp học (classes) nhằm chạy thử nghiệm giao diện.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: classes
                      .map((c) => _classCard(
                          c['title'] ?? "N/A",
                          c['time'] ?? "N/A",
                          c['room'] ?? "N/A",
                          c['trainer'] ?? "N/A",
                          Colors.deepPurple))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _classCard(
      String title, String time, String room, String trainer, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha:  0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:  0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(time,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(room, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(trainer,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
