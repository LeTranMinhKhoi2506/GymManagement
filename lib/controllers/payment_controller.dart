import 'package:flutter/material.dart';
import '../data/models/payment_model.dart';
import '../data/repository/payment_repository.dart';
import 'package:uuid/uuid.dart';

class PaymentController extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  List<PaymentModel> _payments = [];
  List<PaymentModel> _pendingPayments = [];
  List<PaymentModel> _overduePayments = [];
  List<PaymentModel> _paidPayments = [];

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _paymentStats = {};

  // Getters
  List<PaymentModel> get payments => _payments;
  List<PaymentModel> get pendingPayments => _pendingPayments;
  List<PaymentModel> get overduePayments => _overduePayments;
  List<PaymentModel> get paidPayments => _paidPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get paymentStats => _paymentStats;

  double get totalPendingAmount =>
      _pendingPayments.fold(0, (sum, p) => sum + p.amount);
  double get totalOverdueAmount =>
      _overduePayments.fold(0, (sum, p) => sum + p.amount);
  double get totalPaidAmount =>
      _paidPayments.fold(0, (sum, p) => sum + p.amount);

  // Fetch all payments
  Future<void> fetchAllPayments() async {
    _setLoading(true);
    _clearError();
    try {
      _payments = await _repository.getAllPayments();
      _updatePaymentLists();
      await _fetchPaymentStatistics();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payments by member
  Future<void> fetchPaymentsByMember(String memberId) async {
    _setLoading(true);
    _clearError();
    try {
      _payments = await _repository.getPaymentsByMember(memberId);
      _updatePaymentLists();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payments by status
  Future<void> fetchPaymentsByStatus(String status) async {
    _setLoading(true);
    _clearError();
    try {
      _payments = await _repository.getPaymentsByStatus(status);
      _updatePaymentLists();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch overdue payments
  Future<void> fetchOverduePayments() async {
    _setLoading(true);
    _clearError();
    try {
      _overduePayments = await _repository.getOverduePayments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new payment
  Future<void> createPayment({
    required String memberId,
    required String memberName,
    required String membershipType,
    required double amount,
    required DateTime dueDate,
    required String paymentType,
    String? notes,
  }) async {
    _clearError();
    try {
      const uuid = Uuid();
      final payment = PaymentModel(
        id: uuid.v4(),
        memberId: memberId,
        memberName: memberName,
        membershipType: membershipType,
        amount: amount,
        dueDate: dueDate,
        status: 'Pending',
        paymentMethod: '',
        paymentType: paymentType,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createPayment(payment);
      await fetchAllPayments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Mark payment as paid
  Future<void> markPaymentAsPaid(String paymentId, String paymentMethod) async {
    _clearError();
    try {
      await _repository.markPaymentAsPaid(paymentId, paymentMethod);
      await fetchAllPayments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update payment
  Future<void> updatePayment(PaymentModel payment) async {
    _clearError();
    try {
      final updated = payment.copyWith(updatedAt: DateTime.now());
      await _repository.updatePayment(updated);
      await fetchAllPayments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete payment
  Future<void> deletePayment(String id) async {
    _clearError();
    try {
      await _repository.deletePayment(id);
      await fetchAllPayments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Private methods
  void _updatePaymentLists() {
    _pendingPayments = _payments.where((p) => p.status == 'Pending').toList();
    _overduePayments = _payments.where((p) => p.isOverdue).toList();
    _paidPayments = _payments.where((p) => p.status == 'Paid').toList();
  }

  Future<void> _fetchPaymentStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _paymentStats = await _repository.getPaymentStatistics(
        startOfMonth,
        endOfMonth,
      );
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
