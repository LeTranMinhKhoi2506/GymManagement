import 'package:flutter/material.dart';
import '../data/repository/schedule_repository.dart';
import '../data/models/schedule_model.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  Stream<List<ScheduleModel>> get todaySchedulesStream => _repository.getTodaySchedules();

  Future<void> addSchedule({
    required String staffUid,
    required String staffName,
    required String task,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final schedule = ScheduleModel(
      id: '',
      staffUid: staffUid,
      staffName: staffName,
      task: task,
      startTime: startTime,
      endTime: endTime,
    );
    await _repository.addSchedule(schedule);
  }

  Future<void> updateStatus(String id, String status) async {
    await _repository.updateScheduleStatus(id, status);
  }

  Future<void> deleteSchedule(String id) async {
    await _repository.deleteSchedule(id);
  }
}
