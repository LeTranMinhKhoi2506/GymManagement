import 'package:flutter/material.dart';
import '../data/repository/schedule_repository.dart';
import '../data/models/schedule_model.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  Stream<List<ScheduleModel>> get todaySchedulesStream => _repository.getTodaySchedules();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String _viewMode = 'day'; // 'day', 'week', 'month'
  String get viewMode => _viewMode;

  void setViewMode(String mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void next() {
    if (_viewMode == 'day') {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    } else if (_viewMode == 'week') {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    } else if (_viewMode == 'month') {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }
    notifyListeners();
  }

  void previous() {
    if (_viewMode == 'day') {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    } else if (_viewMode == 'week') {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    } else if (_viewMode == 'month') {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    }
    notifyListeners();
  }

  void jumpToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  Stream<List<ScheduleModel>> get schedulesStream {
    DateTime start;
    DateTime end;

    if (_viewMode == 'day') {
      start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59, 999);
    } else if (_viewMode == 'week') {
      // Start of week (Monday)
      final startOfWeek = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).subtract(Duration(days: _selectedDate.weekday - 1));
      start = startOfWeek;
      end = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    } else { // 'month'
      start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      // Last day of current month
      end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59, 999);
    }

    return _repository.getSchedulesForRange(start, end);
  }

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
