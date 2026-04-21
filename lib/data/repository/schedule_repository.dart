import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ScheduleModel>> getTodaySchedules() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db.collection('schedules')
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduleModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    await _db.collection('schedules').add(schedule.toMap());
  }

  Future<void> updateScheduleStatus(String id, String status) async {
    await _db.collection('schedules').doc(id).update({'status': status});
  }

  Future<void> deleteSchedule(String id) async {
    await _db.collection('schedules').doc(id).delete();
  }
}
