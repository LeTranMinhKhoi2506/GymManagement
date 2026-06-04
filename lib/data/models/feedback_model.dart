import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String message;
  final String status; // 'pending', 'replied', 'resolved'
  final DateTime createdAt;
  final String? adminReply;
  final DateTime? repliedAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.adminReply,
    this.repliedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminReply': adminReply,
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FeedbackModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Ẩn danh',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      adminReply: map['adminReply'],
      repliedAt: map['repliedAt'] != null ? (map['repliedAt'] as Timestamp).toDate() : null,
    );
  }
}
