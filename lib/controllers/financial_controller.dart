import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/repository/financial_repository.dart';
import 'package:uuid/uuid.dart';

class FinancialController extends ChangeNotifier {
  final FinancialRepository _repository = FinancialRepository();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _revenues = [];
  List<TransactionModel> _expenses = [];
  Map<String, double> _revenueByCategory = {};
  Map<String, double> _expenseByCategory = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get revenues => _revenues;
  List<TransactionModel> get expenses => _expenses;
  Map<String, double> get revenueByCategory => _revenueByCategory;
  Map<String, double> get expenseByCategory => _expenseByCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalRevenue =>
      _revenues.fold(0, (sum, t) => sum + (t.status == 'Completed' ? t.amount : 0));
  double get totalExpense =>
      _expenses.fold(0, (sum, t) => sum + (t.status == 'Completed' ? t.amount : 0));
  double get netProfit => totalRevenue - totalExpense;
  double get profitMargin =>
      totalRevenue > 0 ? ((netProfit / totalRevenue) * 100) : 0;

  // Fetch all transactions
  Future<void> fetchAllTransactions() async {
    _setLoading(true);
    _clearError();
    try {
      _transactions = await _repository.getAllTransactions();
      _revenues = _transactions.where((t) => t.type == 'Revenue').toList();
      _expenses = _transactions.where((t) => t.type == 'Expense').toList();
      await _updateCategoryBreakdown();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch transactions by type
  Future<void> fetchTransactionsByType(String type) async {
    _setLoading(true);
    _clearError();
    try {
      final transactions = await _repository.getTransactionsByType(type);
      if (type == 'Revenue') {
        _revenues = transactions;
      } else {
        _expenses = transactions;
      }
      await _updateCategoryBreakdown();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch transactions for date range
  Future<void> fetchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();
    try {
      _transactions = await _repository.getTransactionsByDateRange(startDate, endDate);
      _revenues = _transactions.where((t) => t.type == 'Revenue').toList();
      _expenses = _transactions.where((t) => t.type == 'Expense').toList();
      await _updateCategoryBreakdown();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new transaction
  Future<void> createTransaction({
    required String type,
    required String category,
    required String description,
    required double amount,
    required DateTime transactionDate,
    required String paymentMethod,
    String? relatedMemberId,
    String? relatedStaffId,
    String? notes,
    required String createdBy,
  }) async {
    _clearError();
    try {
      const uuid = Uuid();
      final transaction = TransactionModel(
        id: uuid.v4(),
        type: type,
        category: category,
        description: description,
        amount: amount,
        transactionDate: transactionDate,
        paymentMethod: paymentMethod,
        status: 'Completed',
        relatedMemberId: relatedMemberId,
        relatedStaffId: relatedStaffId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
        notes: notes,
      );
      await _repository.createTransaction(transaction);
      await fetchAllTransactions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    _clearError();
    try {
      final updated = transaction.copyWith(updatedAt: DateTime.now());
      await _repository.updateTransaction(updated);
      await fetchAllTransactions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _clearError();
    try {
      await _repository.deleteTransaction(id);
      await fetchAllTransactions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Private methods
  Future<void> _updateCategoryBreakdown() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _revenueByCategory =
          await _repository.getRevenueByCategory(startOfMonth, endOfMonth);
      _expenseByCategory =
          await _repository.getExpenseByCategory(startOfMonth, endOfMonth);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
