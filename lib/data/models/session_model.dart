import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String userId;
  final String userName;
  final String device;
  final String ipAddress;
  final DateTime loginAt;

  SessionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.device,
    required this.ipAddress,
    required this.loginAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      device: map['device'] ?? 'Unknown',
      ipAddress: map['ipAddress'] ?? '0.0.0.0',
      loginAt: (map['loginAt'] as Timestamp).toDate(),
    );
  }
}
