import 'package:flutter/material.dart';

class LiveActivityPanel extends StatelessWidget {
  const LiveActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hoạt động trực tiếp",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          ),
          const SizedBox(height: 20),
          _activityItem(context, "Marcus Aurelius", "Đã xác minh • 2 phút trước", "ĐANG HOẠT ĐỘNG", const Color(0xFFD2E0FE), const Color(0xFF55637D)),
          _activityItem(context, "Julianna Doe", "Phiên PT • 14 phút trước", "ĐANG HOẠT ĐỘNG", const Color(0xFFD2E0FE), const Color(0xFF55637D)),
          _activityItem(context, "Sam Kendrick", "Hết hạn • 45 phút trước", "CẢNH BÁO", const Color(0xFFFFDAD6), const Color(0xFF93000A)),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đang chuyển đến trang chi tiết nhật ký...")),
                );
              },
              child: const Text(
                "XEM TẤT CẢ NHẬT KÝ",
                style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(BuildContext context, String name, String time, String status, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: Color(0xFFFF6B35)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thông tin chi tiết về $name")),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
