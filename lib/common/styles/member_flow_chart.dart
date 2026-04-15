import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/admin_controller.dart';

class MemberFlowChart extends StatelessWidget {
  final AdminController controller;

  const MemberFlowChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
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
          Text("LƯỢNG HỘI VIÊN",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const Text("Lượng khách",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Expanded(
            child: StreamBuilder<List<double>>(
              stream: controller.memberFlowStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                final maxVal = data.isNotEmpty
                    ? data.reduce((a, b) => a > b ? a : b)
                    : 0.0;

                return BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = [
                              '00:00',
                              '04:00',
                              '08:00',
                              '12:00',
                              '16:00',
                              '20:00'
                            ];
                            if (value.toInt() < labels.length) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(labels[value.toInt()],
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 10)));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data
                        .asMap()
                        .entries
                        .map((e) => _barGroup(e.key, e.value,
                            e.value > 0 && e.value == maxVal))
                        .toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Giờ cao điểm",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("17:30 - 19:00",
                  style: TextStyle(
                      color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("T.gian trung bình",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("72 phút", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, bool isPeak) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isPeak ? const Color(0xFFFF6B35) : const Color(0xFF0A192F),
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: isPeak ? [0] : [],
    );
  }
}
