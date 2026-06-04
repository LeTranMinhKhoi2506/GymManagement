import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payroll_model.dart';

class PayrollRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _payrollCollection = 'payroll';

  // Create a new payroll
  Future<String> createPayroll(PayrollModel payroll) async {
    try {
      final docRef = await _firestore
          .collection(_payrollCollection)
          .add(payroll.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating payroll: $e');
    }
  }

  // Get all payrolls
  Future<List<PayrollModel>> getAllPayrolls() async {
    try {
      final snapshot = await _firestore
          .collection(_payrollCollection)
          .orderBy('paymentMonth', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PayrollModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payrolls: $e');
    }
  }

  // Get payrolls by staff
  Future<List<PayrollModel>> getPayrollsByStaff(String staffId) async {
    try {
      final snapshot = await _firestore
          .collection(_payrollCollection)
          .where('staffId', isEqualTo: staffId)
          .orderBy('paymentMonth', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PayrollModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching staff payrolls: $e');
    }
  }

  // Get payrolls by status
  Future<List<PayrollModel>> getPayrollsByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_payrollCollection)
          .where('status', isEqualTo: status)
          .orderBy('paymentMonth', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PayrollModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payrolls by status: $e');
    }
  }

  // Get payroll by ID
  Future<PayrollModel?> getPayrollById(String id) async {
    try {
      final doc = await _firestore
          .collection(_payrollCollection)
          .doc(id)
          .get();
      if (doc.exists) {
        return PayrollModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching payroll: $e');
    }
  }

  // Update payroll
  Future<void> updatePayroll(PayrollModel payroll) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payroll.id)
          .update(payroll.toMap());
    } catch (e) {
      throw Exception('Error updating payroll: $e');
    }
  }

  // Approve payroll
  Future<void> approvePayroll(String payrollId) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payrollId)
          .update({
        'status': 'Approved',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error approving payroll: $e');
    }
  }

  // Mark payroll as paid
  Future<void> markPayrollAsPaid(String payrollId, String paymentMethod) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payrollId)
          .update({
        'status': 'Paid',
        'paymentDate': Timestamp.fromDate(DateTime.now()),
        'paymentMethod': paymentMethod,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error marking payroll as paid: $e');
    }
  }

  // Delete payroll
  Future<void> deletePayroll(String id) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error deleting payroll: $e');
    }
  }

  // Get payroll statistics for a period
  Future<Map<String, dynamic>> getPayrollStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_payrollCollection)
          .where('paymentMonth',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('paymentMonth',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final payrolls =
          snapshot.docs.map((doc) =>
              PayrollModel.fromMap(doc.data(), doc.id)).toList();

      double totalNetSalary = 0;
      double totalBonus = 0;
      double totalDeductions = 0;
      int staffCount = 0;

      for (var payroll in payrolls) {
        totalNetSalary += payroll.netSalary;
        totalBonus += payroll.bonus;
        totalDeductions += payroll.deductions;
      }

      staffCount = payrolls
          .map((p) => p.staffId)
          .toSet()
          .length;

      return {
        'totalNetSalary': totalNetSalary,
        'totalBonus': totalBonus,
        'totalDeductions': totalDeductions,
        'staffCount': staffCount,
        'totalPayrolls': payrolls.length,
      };
    } catch (e) {
      throw Exception('Error fetching payroll statistics: $e');
    }
  }

  // Stream payrolls for real-time updates
  Stream<List<PayrollModel>> streamPayrolls() {
    return _firestore
        .collection(_payrollCollection)
        .orderBy('paymentMonth', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PayrollModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream payrolls by status
  Stream<List<PayrollModel>> streamPayrollsByStatus(String status) {
    return _firestore
        .collection(_payrollCollection)
        .where('status', isEqualTo: status)
        .orderBy('paymentMonth', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PayrollModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
