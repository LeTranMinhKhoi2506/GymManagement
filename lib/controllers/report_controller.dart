import 'package:flutter/material.dart';
import '../data/models/report_model.dart';
import '../data/repository/report_repository.dart';

class ReportController extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();
  
  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReportController() {
    _init();
  }

  void _init() {
    _repository.getReportsStream().listen((event) {
      _reports = event;
      notifyListeners();
    });
  }

  Future<void> updateReportStatus(String id, String status, {String? adminNote}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateReportStatus(id, status, adminNote: adminNote);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReport(String id) async {
    await _repository.deleteReport(id);
  }
}
