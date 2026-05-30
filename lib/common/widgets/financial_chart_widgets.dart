import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RevenueChartWidget extends StatelessWidget {
  final Map<String, double> revenueByCategory;
  final double totalRevenue;

  const RevenueChartWidget({
    super.key,
    required this.revenueByCategory,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    if (revenueByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có dữ liệu doanh thu'),
          ],
        ),
      );
    }

    final entries = revenueByCategory.entries.toList();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entries[i].value,
                    title:
                        '${(entries[i].value / totalRevenue * 100).toStringAsFixed(1)}%',
                    radius: 100,
                  ),
              ],
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors[index % colors.length],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '₫',
                      locale: 'vi_VN',
                      decimalDigits: 0,
                    ).format(entry.value),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ExpenseChartWidget extends StatelessWidget {
  final Map<String, double> expenseByCategory;
  final double totalExpense;

  const ExpenseChartWidget({
    super.key,
    required this.expenseByCategory,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có dữ liệu chi phí'),
          ],
        ),
      );
    }

    final entries = expenseByCategory.entries.toList();
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.amber,
      Colors.deepOrange,
    ];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entries[i].value,
                    title:
                        '${(entries[i].value / totalExpense * 100).toStringAsFixed(1)}%',
                    radius: 100,
                  ),
              ],
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors[index % colors.length],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '₫',
                      locale: 'vi_VN',
                      decimalDigits: 0,
                    ).format(entry.value),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfitTrendChartWidget extends StatelessWidget {
  final List<double> revenues;
  final List<double> expenses;
  final List<String> months;

  const ProfitTrendChartWidget({
    super.key,
    required this.revenues,
    required this.expenses,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}M',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < revenues.length; i++)
                FlSpot(i.toDouble(), revenues[i])
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [
              for (int i = 0; i < expenses.length; i++)
                FlSpot(i.toDouble(), expenses[i])
            ],
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
