import 'package:flutter/material.dart';
import '../data/repository/admin_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  List<double> _monthlyRevenue = List.filled(12, 0.0);
  List<double> get monthlyRevenue => _monthlyRevenue;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lấy dữ liệu khởi tạo cho biểu đồ (Vì biểu đồ LineChart khó làm stream toàn phần)
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _monthlyRevenue = await _repository.getMonthlyRevenue();
    } catch (e) {
      debugPrint("AdminController - fetchDashboardStats error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // STREAMS REAL-TIME
  Stream<int> get totalMembersStream => _repository.getTotalMembersStream();
  Stream<int> get staffCountStream => _repository.getStaffCountStream();
  Stream<double> get todayRevenueStream => _repository.getTodayRevenueStream();
  Stream<List<double>> get memberFlowStream => _repository.getMemberFlowStream();
  Stream<QuerySnapshot> get recentCheckinsStream => _repository.getRecentCheckins();
  Stream<List<Map<String, dynamic>>> get upcomingClassesStream => _repository.getUpcomingClassesStream();
  Stream<List<Map<String, dynamic>>> get equipmentStatusStream => _repository.getEquipmentStatusStream();
}
