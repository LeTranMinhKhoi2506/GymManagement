import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _paymentsCollection = 'member_payments';

  // Create a new payment
  Future<String> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore
          .collection(_paymentsCollection)
          .add(payment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Get all payments
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .orderBy('dueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  // Get payments by member
  Future<List<PaymentModel>> getPaymentsByMember(String memberId) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('memberId', isEqualTo: memberId)
          .orderBy('dueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching member payments: $e');
    }
  }

  // Get payments by status
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('status', isEqualTo: status)
          .orderBy('dueDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payments by status: $e');
    }
  }

  // Get overdue payments
  Future<List<PaymentModel>> getOverduePayments() async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('status', isEqualTo: 'Pending')
          .where('dueDate', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get();
      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching overdue payments: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final doc = await _firestore
          .collection(_paymentsCollection)
          .doc(id)
          .get();
      if (doc.exists) {
        return PaymentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  // Update payment
  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _firestore
          .collection(_paymentsCollection)
          .doc(payment.id)
          .update(payment.toMap());
    } catch (e) {
      throw Exception('Error updating payment: $e');
    }
  }

  // Mark payment as paid
  Future<void> markPaymentAsPaid(String paymentId, String paymentMethod) async {
    try {
      await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'Paid',
        'paymentDate': Timestamp.fromDate(DateTime.now()),
        'paymentMethod': paymentMethod,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error marking payment as paid: $e');
    }
  }

  // Delete payment
  Future<void> deletePayment(String id) async {
    try {
      await _firestore
          .collection(_paymentsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error deleting payment: $e');
    }
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final payments =
          snapshot.docs.map((doc) =>
              PaymentModel.fromMap(doc.data(), doc.id)).toList();

      double totalAmount = 0;
      int paidCount = 0;
      int pendingCount = 0;
      int overdueCount = 0;

      for (var payment in payments) {
        totalAmount += payment.amount;
        if (payment.status == 'Paid') {
          paidCount++;
        } else if (payment.status == 'Pending') {
          pendingCount++;
        } else if (payment.status == 'Overdue') {
          overdueCount++;
        }
      }

      return {
        'totalAmount': totalAmount,
        'paidCount': paidCount,
        'pendingCount': pendingCount,
        'overdueCount': overdueCount,
        'totalPayments': payments.length,
      };
    } catch (e) {
      throw Exception('Error fetching payment statistics: $e');
    }
  }

  // Stream payments for real-time updates
  Stream<List<PaymentModel>> streamPayments() {
    return _firestore
        .collection(_paymentsCollection)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream payments by status
  Stream<List<PaymentModel>> streamPaymentsByStatus(String status) {
    return _firestore
        .collection(_paymentsCollection)
        .where('status', isEqualTo: status)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
