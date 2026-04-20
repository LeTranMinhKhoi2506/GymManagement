import 'package:flutter/material.dart';

class QuickCheckInPanel extends StatelessWidget {
  final TextEditingController controller;
  const QuickCheckInPanel({super.key, required this.controller});

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Check-in nhanh",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
              ),
              Icon(Icons.qr_code_scanner, color: Color(0xFFFF6B35)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Tên thành viên hoặc ID QR",
              filled: true,
              fillColor: const Color(0xFFF3F4F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã xác nhận truy cập cho: ${controller.text}")),
                  );
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A192F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("XÁC NHẬN TRUY CẬP", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
