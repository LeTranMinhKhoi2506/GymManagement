import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // STREAM: Tổng số hội viên real-time
  Stream<int> getTotalMembersStream() {
    return _db.collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // STREAM: Số lượng nhân viên real-time
  Stream<int> getStaffCountStream() {
    return _db.collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // STREAM: Doanh thu hôm nay real-time
  Stream<double> getTodayRevenueStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    
    return _db.collection('payments')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
          double total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }
          return total;
        });
  }

  // STREAM: Doanh thu 12 tháng gần nhất (Cập nhật khi có payment mới)
  Stream<List<double>> getMonthlyRevenueStream() {
    return _db.collection('payments').snapshots().map((_) {
      // Vì Firestore không hỗ trợ query phức tạp cho 12 tháng trong 1 stream dễ dàng,
      // Ta sẽ trigger tính toán lại mỗi khi có thay đổi ở collection payments.
      // Lưu ý: Trong thực tế nên tối ưu hóa phần này.
      return []; // Sẽ được xử lý ở Controller hoặc gọi hàm Future hiện tại
    });
  }

  // Lấy dữ liệu doanh thu theo tháng (Vẫn giữ hàm Future để fetch ban đầu)
  Future<List<double>> getMonthlyRevenue() async {
    try {
      List<double> monthlyRevenue = List.filled(12, 0.0);
      DateTime now = DateTime.now();
      for (int i = 0; i < 12; i++) {
        DateTime startOfMonth = DateTime(now.year, now.month - (11 - i), 1);
        DateTime endOfMonth = DateTime(now.year, now.month - (11 - i) + 1, 0, 23, 59, 59);
        var snapshot = await _db.collection('payments')
            .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
            .where('timestamp', isLessThanOrEqualTo: endOfMonth)
            .get();
        double total = 0;
        for (var doc in snapshot.docs) {
          total += (doc.data()['amount'] ?? 0).toDouble();
        }
        monthlyRevenue[i] = total;
      }
      return monthlyRevenue;
    } catch (e) {
      return List.filled(12, 0.0);
    }
  }

  // STREAM: Lượng khách theo khung giờ REAL-TIME
  Stream<List<double>> getMemberFlowStream() {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);

    return _db.collection('checkins')
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .snapshots()
        .map((snapshot) {
          List<double> flow = List.filled(6, 0.0);
          for (var doc in snapshot.docs) {
            var data = doc.data();
            if (data['timestamp'] != null) {
              DateTime time = (data['timestamp'] as Timestamp).toDate();
              int hour = time.hour;
              int index = hour ~/ 4;
              if (index >= 0 && index < 6) {
                flow[index]++;
              }
            }
          }
          return flow;
        });
  }

  // Stream lấy danh sách check-in gần đây
  Stream<QuerySnapshot> getRecentCheckins() {
    return _db.collection('checkins')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

  // STREAM: Lớp học real-time
  Stream<List<Map<String, dynamic>>> getUpcomingClassesStream() {
    return _db.collection('classes')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // STREAM: Thiết bị real-time
  Stream<List<Map<String, dynamic>>> getEquipmentStatusStream() {
    return _db.collection('equipment')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
