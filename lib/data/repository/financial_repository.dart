import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FinancialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _transactionsCollection = 'transactions';

  // Create a new transaction
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection(_transactionsCollection)
          .add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  // Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // Get transactions by type (Revenue or Expense)
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('type', isEqualTo: type)
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions by type: $e');
    }
  }

  // Get transactions by category
  Future<List<TransactionModel>> getTransactionsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('category', isEqualTo: category)
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions by category: $e');
    }
  }

  // Get transactions for a date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transactionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('transactionDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions by date range: $e');
    }
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final doc = await _firestore
          .collection(_transactionsCollection)
          .doc(id)
          .get();
      if (doc.exists) {
        return TransactionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // Get total revenue for a period
  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      final revenue = transactions
          .where((t) => t.type == 'Revenue' && t.status == 'Completed')
          .fold<double>(0, (total, t) => total + t.amount);
      return revenue;
    } catch (e) {
      throw Exception('Error calculating total revenue: $e');
    }
  }

  // Get total expense for a period
  Future<double> getTotalExpense(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      final expense = transactions
          .where((t) => t.type == 'Expense' && t.status == 'Completed')
          .fold<double>(0, (total, t) => total + t.amount);
      return expense;
    } catch (e) {
      throw Exception('Error calculating total expense: $e');
    }
  }

  // Get revenue by category
  Future<Map<String, double>> getRevenueByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      final Map<String, double> categoryMap = {};
      for (var t in transactions) {
        if (t.type == 'Revenue' && t.status == 'Completed') {
          categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
        }
      }
      return categoryMap;
    } catch (e) {
      throw Exception('Error fetching revenue by category: $e');
    }
  }

  // Get expense by category
  Future<Map<String, double>> getExpenseByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      final Map<String, double> categoryMap = {};
      for (var t in transactions) {
        if (t.type == 'Expense' && t.status == 'Completed') {
          categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
        }
      }
      return categoryMap;
    } catch (e) {
      throw Exception('Error fetching expense by category: $e');
    }
  }

  // Stream transactions for real-time updates
  Stream<List<TransactionModel>> streamTransactions() {
    return _firestore
        .collection(_transactionsCollection)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TransactionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream transactions by type
  Stream<List<TransactionModel>> streamTransactionsByType(String type) {
    return _firestore
        .collection(_transactionsCollection)
        .where('type', isEqualTo: type)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TransactionModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
