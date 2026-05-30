import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionTableWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onTap;

  const TransactionTableWidget({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Không có giao dịch nào'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₫',
      locale: 'vi_VN',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Ngày')),
          DataColumn(label: Text('Loại')),
          DataColumn(label: Text('Danh Mục')),
          DataColumn(label: Text('Mô Tả')),
          DataColumn(label: Text('Số Tiền')),
          DataColumn(label: Text('Trạng Thái')),
        ],
        rows: [
          for (var transaction in transactions)
            DataRow(
              onSelectChanged: (_) => onTap(transaction),
              cells: [
                DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(transaction.transactionDate)),
                ),
                DataCell(
                  Text(transaction.type),
                ),
                DataCell(
                  Text(transaction.category),
                ),
                DataCell(
                  Text(transaction.description),
                ),
                DataCell(
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == 'Revenue'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(transaction.status),
                    backgroundColor: transaction.status == 'Completed'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
