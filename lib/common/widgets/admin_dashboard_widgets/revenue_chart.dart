import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/admin_controller.dart';

class RevenueChart extends StatelessWidget {
  final AdminController controller;

  const RevenueChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isMonthly = controller.isMonthly;
    final List<double> data = isMonthly ? controller.monthlyRevenue : controller.weeklyRevenue;

    return Container(
      height: 450,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PHÂN TÍCH TÀI CHÍNH",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const Text("Doanh thu",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  _buildChartTab("Hàng tuần", !isMonthly, () => controller.setChartType(false)),
                  const SizedBox(width: 8),
                  _buildChartTab("Hàng tháng", isMonthly, () => controller.setChartType(true)),
                ],
              )
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (isMonthly) {
                          const months = ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(months[value.toInt()],
                                    style: const TextStyle(color: Colors.grey, fontSize: 10)));
                          }
                        } else {
                          const days = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
                          // Map index to labels - assuming data is for the last 7 days
                          if (value.toInt() >= 0 && value.toInt() < 7) {
                            return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("D${value.toInt() + 1}", // Simplified label or could use actual day names
                                    style: const TextStyle(color: Colors.grey, fontSize: 10)));
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFFF6B35),
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B35).withValues(alpha: 0.2),
                          const Color(0xFFFF6B35).withValues(alpha: 0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A192F) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
