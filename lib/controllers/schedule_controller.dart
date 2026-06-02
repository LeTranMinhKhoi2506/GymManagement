import 'package:flutter/material.dart';
import '../data/repository/schedule_repository.dart';
import '../data/models/schedule_model.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  Stream<List<ScheduleModel>> get todaySchedulesStream => _repository.getTodaySchedules();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addSchedule({
    required String staffUid,
    required String staffName,
    required String task,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final schedule = ScheduleModel(
        id: '',
        staffUid: staffUid,
        staffName: staffName,
        task: task,
        startTime: startTime,
        endTime: endTime,
      );
      await _repository.addSchedule(schedule);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateScheduleStatus(id, status);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteSchedule(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
