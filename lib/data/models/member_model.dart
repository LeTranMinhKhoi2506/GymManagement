import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String membershipType; // 'Pro Elite', 'Standard', 'Trial'
  final String status; // 'Active', 'Inactive', 'Expired', 'Payment Overdue'
  final bool isCurrentlyTraining;
  final DateTime? nextRenewal;
  final DateTime? memberSince;
  final String? profileImageUrl;
  final double ltv; // Lifetime Value
  final List<ActivityLog>? activityLogs;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.membershipType,
    required this.status,
    this.isCurrentlyTraining = false,
    this.nextRenewal,
    this.memberSince,
    this.profileImageUrl,
    this.ltv = 0.0,
    this.activityLogs,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MemberModel(
      id: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      membershipType: map['membershipType'] ?? 'Standard',
      status: map['status'] ?? 'Active',
      isCurrentlyTraining: map['isCurrentlyTraining'] ?? false,
      nextRenewal: map['nextRenewal'] != null ? (map['nextRenewal'] as Timestamp).toDate() : null,
      memberSince: map['memberSince'] != null ? (map['memberSince'] as Timestamp).toDate() : null,
      profileImageUrl: map['profileImageUrl'],
      ltv: (map['ltv'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'membershipType': membershipType,
      'status': status,
      'isCurrentlyTraining': isCurrentlyTraining,
      'nextRenewal': nextRenewal != null ? Timestamp.fromDate(nextRenewal!) : null,
      'memberSince': memberSince != null ? Timestamp.fromDate(memberSince!) : FieldValue.serverTimestamp(),
      'profileImageUrl': profileImageUrl,
      'ltv': ltv,
    };
  }
}

class ActivityLog {
  final String title;
  final DateTime timestamp;
  final double amount;
  final String status; // 'Paid', 'Pending'
  final String type; // 'Renewal', 'Product', 'Session'

  ActivityLog({
    required this.title,
    required this.timestamp,
    required this.amount,
    required this.status,
    required this.type,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      title: map['title'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Paid',
      type: map['type'] ?? 'Renewal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
      'amount': amount,
      'status': status,
      'type': type,
    };
  }
}
