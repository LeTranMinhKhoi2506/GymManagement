import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedItemId; // ID của user hoặc content bị báo cáo
  final String type; // 'user', 'content', 'feedback'
  final String reason;
  final String status; // 'pending', 'investigating', 'resolved', 'dismissed'
  final DateTime createdAt;
  final String? adminNote;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedItemId,
    required this.type,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.adminNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedItemId': reportedItemId,
      'type': type,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminNote': adminNote,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reportedItemId: map['reportedItemId'] ?? '',
      type: map['type'] ?? 'user',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      adminNote: map['adminNote'],
    );
  }
}
