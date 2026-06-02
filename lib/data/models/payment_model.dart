import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String memberId;
  final String memberName;
  final String membershipType;
  final double amount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String status; // 'Paid', 'Pending', 'Overdue', 'Cancelled'
  final String paymentMethod; // 'Cash', 'Card', 'Transfer', 'Cheque'
  final String paymentType; // 'Membership', 'Training', 'Product'
  final String? transactionId; // Link to transaction record
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.membershipType,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    required this.status,
    required this.paymentMethod,
    required this.paymentType,
    this.transactionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentModel(
      id: documentId,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      membershipType: map['membershipType'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.now(),
      paymentDate: map['paymentDate'] != null
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentType: map['paymentType'] ?? 'Membership',
      transactionId: map['transactionId'],
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'membershipType': membershipType,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentType': paymentType,
      'transactionId': transactionId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? membershipType,
    double? amount,
    DateTime? dueDate,
    DateTime? paymentDate,
    String? status,
    String? paymentMethod,
    String? paymentType,
    String? transactionId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      membershipType: membershipType ?? this.membershipType,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue => status == 'Pending' && DateTime.now().isAfter(dueDate);
}
