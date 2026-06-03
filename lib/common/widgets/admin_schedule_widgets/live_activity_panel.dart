import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('checkins')
                .orderBy('timestamp', descending: true)
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Lỗi khi tải nhật ký trực tiếp", style: TextStyle(color: Colors.redAccent, fontSize: 13));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "Chưa có hoạt động check-in nào.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['userName'] ?? 'Hội viên';
                  final zone = data['zone'] ?? 'Khu vực chính';
                  
                  DateTime? time;
                  if (data['timestamp'] != null) {
                    time = (data['timestamp'] as Timestamp).toDate();
                  }
                  final String timeStr = time != null 
                      ? "${DateFormat('HH:mm dd/MM/yyyy').format(time)} • ${_getRelativeTime(time)}"
                      : "Vừa xong";

                  final isCheckIn = zone.contains('Check-in') || zone.contains('vào');
                  final statusLabel = isCheckIn ? 'CHECK-IN' : 'CHECK-OUT';
                  final bgColor = isCheckIn 
                      ? const Color(0xFFE2F0D9) 
                      : const Color(0xFFFFE0B2).withValues(alpha: 0.5);
                  final textColor = isCheckIn 
                      ? Colors.green[800]! 
                      : Colors.orange[900]!;

                  return _activityItem(context, name, timeStr, statusLabel, bgColor, textColor);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return "Vừa xong";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    } else {
      return "${diff.inDays} ngày trước";
    }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
