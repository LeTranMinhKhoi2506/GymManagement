import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';

class EquipmentStatusStream extends StatelessWidget {
  final AdminController controller;

  const EquipmentStatusStream({super.key, required this.controller});

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
          const Text("Tình trạng thiết bị",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.equipmentStatusStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final equipment = snapshot.data!;
              if (equipment.isEmpty) {
                return const Text("Chưa có dữ liệu thiết bị");
              }
              return Column(
                children: equipment
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _equipmentItem(
                              e['name'] ?? "Thiết bị",
                              (e['total'] != null && e['total'] > 0)
                                  ? (e['operational'] ?? 0) / e['total']
                                  : 0.0,
                              "${e['operational'] ?? 0}/${e['total'] ?? 0} Hoạt động",
                              (e['operational'] ?? 0) == (e['total'] ?? 0)
                                  ? Colors.green
                                  : Colors.orange),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _equipmentItem(
      String title, double progress, String status, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(status,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}
