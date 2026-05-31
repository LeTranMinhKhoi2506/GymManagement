import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'general', 'promotion', 'alert', 'individual'
  final DateTime createdAt;
  final String? targetUserId; // null if broadcast
  final bool isRead;
  final String? sentBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.targetUserId,
    this.isRead = false,
    this.sentBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetUserId': targetUserId,
      'isRead': isRead,
      'sentBy': sentBy,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      targetUserId: map['targetUserId'],
      isRead: map['isRead'] ?? false,
      sentBy: map['sentBy'],
    );
  }
}
