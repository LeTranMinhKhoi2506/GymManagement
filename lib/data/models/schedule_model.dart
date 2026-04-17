import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String staffUid;
  final String staffName;
  final String task;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'ongoing', 'completed'

  ScheduleModel({
    required this.id,
    required this.staffUid,
    required this.staffName,
    required this.task,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffUid': staffUid,
      'staffName': staffName,
      'task': task,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ScheduleModel(
      id: docId,
      staffUid: map['staffUid'] ?? '',
      staffName: map['staffName'] ?? '',
      task: map['task'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }
}
