class FinancialReportModel {
  final String id;
  final DateTime reportDate;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;
  final double profitMargin;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expenseByCategory;
  final int totalTransactions;
  final int totalMembers;
  final double averageTransactionAmount;

  FinancialReportModel({
    required this.id,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
    required this.profitMargin,
    required this.revenueByCategory,
    required this.expenseByCategory,
    required this.totalTransactions,
    required this.totalMembers,
    required this.averageTransactionAmount,
  });

  factory FinancialReportModel.fromMap(Map<String, dynamic> map, String documentId) {
    final totalRevenue = (map['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalExpense = (map['totalExpense'] as num?)?.toDouble() ?? 0.0;
    final netProfit = totalRevenue - totalExpense;
    final profitMargin =
        totalRevenue > 0 ? ((netProfit / totalRevenue) * 100) : 0.0;

    return FinancialReportModel(
      id: documentId,
      reportDate: map['reportDate'] != null
          ? DateTime.parse(map['reportDate'])
          : DateTime.now(),
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now(),
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
      netProfit: netProfit,
      profitMargin: profitMargin,
      revenueByCategory: Map<String, double>.from(
        map['revenueByCategory'] ?? {},
      ),
      expenseByCategory: Map<String, double>.from(
        map['expenseByCategory'] ?? {},
      ),
      totalTransactions: map['totalTransactions'] ?? 0,
      totalMembers: map['totalMembers'] ?? 0,
      averageTransactionAmount:
          (map['averageTransactionAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportDate': reportDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalExpense': totalExpense,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
      'revenueByCategory': revenueByCategory,
      'expenseByCategory': expenseByCategory,
      'totalTransactions': totalTransactions,
      'totalMembers': totalMembers,
      'averageTransactionAmount': averageTransactionAmount,
    };
  }

  bool get isProfit => netProfit > 0;
}
