import 'package:cloud_firestore/cloud_firestore.dart';

class PayrollModel {
  final String id;
  final String staffId;
  final String staffName;
  final String position;
  final double baseSalary;
  final DateTime paymentMonth; // Month for this payroll
  final int workingDays;
  final double bonus;
  final double deductions; // Tax, insurance, etc.
  final double netSalary;
  final String status; // 'Pending', 'Approved', 'Paid', 'Cancelled'
  final String? paymentMethod; // 'Bank Transfer', 'Cash'
  final DateTime? paymentDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Admin who created payroll

  PayrollModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.position,
    required this.baseSalary,
    required this.paymentMonth,
    required this.workingDays,
    required this.bonus,
    required this.deductions,
    required this.netSalary,
    required this.status,
    this.paymentMethod,
    this.paymentDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory PayrollModel.fromMap(Map<String, dynamic> map, String documentId) {
    final baseSalary = (map['baseSalary'] as num?)?.toDouble() ?? 0.0;
    final bonus = (map['bonus'] as num?)?.toDouble() ?? 0.0;
    final deductions = (map['deductions'] as num?)?.toDouble() ?? 0.0;

    return PayrollModel(
      id: documentId,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      position: map['position'] ?? '',
      baseSalary: baseSalary,
      paymentMonth: map['paymentMonth'] != null
          ? (map['paymentMonth'] as Timestamp).toDate()
          : DateTime.now(),
      workingDays: map['workingDays'] ?? 0,
      bonus: bonus,
      deductions: deductions,
      netSalary: (map['netSalary'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'],
      paymentDate: map['paymentDate'] != null
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'position': position,
      'baseSalary': baseSalary,
      'paymentMonth': Timestamp.fromDate(paymentMonth),
      'workingDays': workingDays,
      'bonus': bonus,
      'deductions': deductions,
      'netSalary': netSalary,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  PayrollModel copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? position,
    double? baseSalary,
    DateTime? paymentMonth,
    int? workingDays,
    double? bonus,
    double? deductions,
    double? netSalary,
    String? status,
    String? paymentMethod,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      position: position ?? this.position,
      baseSalary: baseSalary ?? this.baseSalary,
      paymentMonth: paymentMonth ?? this.paymentMonth,
      workingDays: workingDays ?? this.workingDays,
      bonus: bonus ?? this.bonus,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  double get dailyRate => baseSalary / 22; // Assuming 22 working days per month
}
