import 'package:flutter/material.dart';
import '../data/models/payroll_model.dart';
import '../data/repository/payroll_repository.dart';
import 'package:uuid/uuid.dart';

class PayrollController extends ChangeNotifier {
  final PayrollRepository _repository = PayrollRepository();

  List<PayrollModel> _payrolls = [];
  List<PayrollModel> _pendingPayrolls = [];
  List<PayrollModel> _approvedPayrolls = [];
  List<PayrollModel> _paidPayrolls = [];

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _payrollStats = {};

  // Getters
  List<PayrollModel> get payrolls => _payrolls;
  List<PayrollModel> get pendingPayrolls => _pendingPayrolls;
  List<PayrollModel> get approvedPayrolls => _approvedPayrolls;
  List<PayrollModel> get paidPayrolls => _paidPayrolls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get payrollStats => _payrollStats;

  double get totalNetSalary =>
      _payrolls.fold(0, (sum, p) => sum + p.netSalary);
  double get totalBonus => _payrolls.fold(0, (sum, p) => sum + p.bonus);
  double get totalDeductions =>
      _payrolls.fold(0, (sum, p) => sum + p.deductions);

  // Fetch all payrolls
  Future<void> fetchAllPayrolls() async {
    _setLoading(true);
    _clearError();
    try {
      _payrolls = await _repository.getAllPayrolls();
      _updatePayrollLists();
      await _fetchPayrollStatistics();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payrolls by staff
  Future<void> fetchPayrollsByStaff(String staffId) async {
    _setLoading(true);
    _clearError();
    try {
      _payrolls = await _repository.getPayrollsByStaff(staffId);
      _updatePayrollLists();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payrolls by status
  Future<void> fetchPayrollsByStatus(String status) async {
    _setLoading(true);
    _clearError();
    try {
      _payrolls = await _repository.getPayrollsByStatus(status);
      _updatePayrollLists();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new payroll
  Future<void> createPayroll({
    required String staffId,
    required String staffName,
    required String position,
    required double baseSalary,
    required DateTime paymentMonth,
    required int workingDays,
    double bonus = 0,
    double deductions = 0,
    String? notes,
    required String createdBy,
  }) async {
    _clearError();
    try {
      final netSalary = baseSalary + bonus - deductions;
      const uuid = Uuid();
      final payroll = PayrollModel(
        id: uuid.v4(),
        staffId: staffId,
        staffName: staffName,
        position: position,
        baseSalary: baseSalary,
        paymentMonth: paymentMonth,
        workingDays: workingDays,
        bonus: bonus,
        deductions: deductions,
        netSalary: netSalary,
        status: 'Pending',
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
      );
      await _repository.createPayroll(payroll);
      await fetchAllPayrolls();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Approve payroll
  Future<void> approvePayroll(String payrollId) async {
    _clearError();
    try {
      await _repository.approvePayroll(payrollId);
      await fetchAllPayrolls();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Mark payroll as paid
  Future<void> markPayrollAsPaid(String payrollId, String paymentMethod) async {
    _clearError();
    try {
      await _repository.markPayrollAsPaid(payrollId, paymentMethod);
      await fetchAllPayrolls();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update payroll
  Future<void> updatePayroll(PayrollModel payroll) async {
    _clearError();
    try {
      final updated = payroll.copyWith(updatedAt: DateTime.now());
      await _repository.updatePayroll(updated);
      await fetchAllPayrolls();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete payroll
  Future<void> deletePayroll(String id) async {
    _clearError();
    try {
      await _repository.deletePayroll(id);
      await fetchAllPayrolls();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Private methods
  void _updatePayrollLists() {
    _pendingPayrolls = _payrolls.where((p) => p.status == 'Pending').toList();
    _approvedPayrolls = _payrolls.where((p) => p.status == 'Approved').toList();
    _paidPayrolls = _payrolls.where((p) => p.status == 'Paid').toList();
  }

  Future<void> _fetchPayrollStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _payrollStats = await _repository.getPayrollStatistics(
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
