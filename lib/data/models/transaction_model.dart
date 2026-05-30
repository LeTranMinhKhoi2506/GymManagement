import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // 'Revenue' or 'Expense'
  final String category; // Revenue: 'Membership', 'Training', 'Product', 'Service'
                         // Expense: 'Equipment', 'Utilities', 'Maintenance', 'Marketing', 'Other'
  final String description;
  final double amount;
  final DateTime transactionDate;
  final String paymentMethod; // 'Cash', 'Card', 'Transfer', 'Cheque'
  final String status; // 'Completed', 'Pending', 'Cancelled'
  final String? relatedMemberId; // For member-related transactions
  final String? relatedStaffId; // For staff-related transactions
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Admin who created the transaction
  final String? notes;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.paymentMethod,
    required this.status,
    this.relatedMemberId,
    this.relatedStaffId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.notes,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      type: map['type'] ?? 'Revenue',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: map['transactionDate'] != null
          ? (map['transactionDate'] as Timestamp).toDate()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      status: map['status'] ?? 'Completed',
      relatedMemberId: map['relatedMemberId'],
      relatedStaffId: map['relatedStaffId'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'paymentMethod': paymentMethod,
      'status': status,
      'relatedMemberId': relatedMemberId,
      'relatedStaffId': relatedStaffId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'notes': notes,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    String? category,
    String? description,
    double? amount,
    DateTime? transactionDate,
    String? paymentMethod,
    String? status,
    String? relatedMemberId,
    String? relatedStaffId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      relatedMemberId: relatedMemberId ?? this.relatedMemberId,
      relatedStaffId: relatedStaffId ?? this.relatedStaffId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
    );
  }
}
