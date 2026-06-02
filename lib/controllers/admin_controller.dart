import 'package:flutter/material.dart';
import '../data/repository/admin_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  List<double> _monthlyRevenue = List.filled(12, 0.0);
  List<double> get monthlyRevenue => _monthlyRevenue;

  List<double> _weeklyRevenue = List.filled(7, 0.0);
  List<double> get weeklyRevenue => _weeklyRevenue;

  bool _isMonthly = true;
  bool get isMonthly => _isMonthly;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lấy dữ liệu khởi tạo cho biểu đồ
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      await refreshData();
    } catch (e) {
      debugPrint("AdminController - fetchDashboardStats error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _monthlyRevenue = await _repository.getMonthlyRevenue();
    _weeklyRevenue = await _repository.getWeeklyRevenue();
    notifyListeners();
  }

  void setChartType(bool monthly) {
    _isMonthly = monthly;
    notifyListeners();
  }

  // STREAMS REAL-TIME
  Stream<int> get totalMembersStream => _repository.getTotalMembersStream();
  Stream<Map<String, dynamic>> get membersGrowthStream => _repository.getMembersGrowthStream();
  
  Stream<int> get activeStaffCountStream => _repository.getActiveStaffCountStream();
  Stream<int> get totalStaffStream => _repository.getTotalStaffStream();
  
  Stream<double> get todayRevenueStream => _repository.getTodayRevenueStream();
  Stream<Map<String, dynamic>> get revenueStatusStream => _repository.getRevenueStatusStream();

  Stream<List<double>> get memberFlowStream => _repository.getMemberFlowStream();
  Stream<QuerySnapshot> get recentCheckinsStream => _repository.getRecentCheckins();
  Stream<List<Map<String, dynamic>>> get upcomingClassesStream => _repository.getUpcomingClassesStream();
  Stream<List<Map<String, dynamic>>> get equipmentStatusStream => _repository.getEquipmentStatusStream();
  
  // Stream để trigger cập nhật biểu đồ doanh thu khi có payment mới
  Stream<QuerySnapshot> get paymentsUpdateStream => FirebaseFirestore.instance.collection('payments').snapshots();
}
