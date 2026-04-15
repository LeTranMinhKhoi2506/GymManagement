import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class RecentCheckinsLog extends StatelessWidget {
  final AdminController controller;

  const RecentCheckinsLog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha:  0.04), blurRadius: 20)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lịch sử ra vào gần đây",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: controller.recentCheckinsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Text("Chưa có lượt ra vào nào.");
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  DateTime? time;
                  if (data['timestamp'] != null) {
                    time = (data['timestamp'] as Timestamp).toDate();
                  }
                  String timeStr =
                      time != null ? DateFormat('HH:mm').format(time) : "Vừa xong";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.person,
                                size: 16, color: Colors.white)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(data['userName'] ?? "Hội viên",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                        Text(data['zone'] ?? "Khu vực chính",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(width: 32),
                        Text(timeStr,
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
