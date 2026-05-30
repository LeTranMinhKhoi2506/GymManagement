import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialSummaryWidget extends StatelessWidget {
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;
  final double profitMargin;
  final int totalTransactions;

  const FinancialSummaryWidget({
    super.key,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
    required this.profitMargin,
    required this.totalTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.withValues(alpha: 0.1), Colors.purple.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tóm Tắt Tài Chính',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  label: 'Doanh Thu',
                  value: currencyFormat.format(totalRevenue),
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  label: 'Chi Phí',
                  value: currencyFormat.format(totalExpense),
                  color: Colors.red,
                ),
                _buildSummaryItem(
                  label: 'Lợi Nhuận',
                  value: currencyFormat.format(netProfit),
                  color: netProfit > 0 ? Colors.blue : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  label: 'Tỷ Lợi Nhuận',
                  value: '${profitMargin.toStringAsFixed(1)}%',
                  color: Colors.purple,
                ),
                _buildSummaryItem(
                  label: 'Tổng Giao Dịch',
                  value: '$totalTransactions',
                  color: Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
