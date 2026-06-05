import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<int> getTotalMembersStream() {
    return _db.collection('users')
        .where('role', whereIn: const ['user', 'member'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) => 0);
  }

  Stream<Map<String, dynamic>> getMembersGrowthStream() {
    return _db.collection('users')
        .where('role', whereIn: const ['user', 'member'])
        .snapshots()
        .asyncMap((snapshot) async {
          int current = snapshot.docs.length;
          DateTime now = DateTime.now();
          DateTime startOfLastMonth = DateTime(now.year, now.month - 1, 1);
          DateTime endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

          var lastMonthSnapshot = await _db.collection('users')
              .where('role', whereIn: const ['user', 'member'])
              .where('createdAt', isGreaterThanOrEqualTo: startOfLastMonth)
              .where('createdAt', isLessThanOrEqualTo: endOfLastMonth)
              .get();
          
          int lastMonthCount = lastMonthSnapshot.docs.length;
          double growth = 0;
          String status = "STABLE";
          
          if (lastMonthCount > 0) {
            growth = ((current - lastMonthCount) / lastMonthCount) * 100;
            if (growth > 10) {
              status = "PEAK";
            } else if (growth < -10) {
              status = "DROPPING";
            }
          } else {
            growth = current > 0 ? 100 : 0;
            status = current > 0 ? "PEAK" : "STABLE";
          }

          return {
            "value": "${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%",
            "status": status
          };
        });
  }

  // STREAM: Số nhân viên đang online/active (giả định dựa trên field status hoặc checkin)
  Stream<int> getActiveStaffCountStream() {
    return _db.collection('users')
        .where('role', isEqualTo: 'staff')
        .where('status', isEqualTo: 'active') // Bạn cần có field status: 'active' trong Firestore
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) => 0);
  }

  // STREAM: Tổng số nhân viên trong hệ thống
  Stream<int> getTotalStaffStream() {
    return _db.collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) => 0);
  }

  Stream<double> getTodayRevenueStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    return _db.collection('payments')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
          double total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }
          return total;
        });
  }

  Stream<Map<String, dynamic>> getRevenueStatusStream() {
    return _db.collection('payments').snapshots().asyncMap((_) async {
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);
      DateTime startOfYesterday = DateTime(now.year, now.month, now.day - 1);
      
      var todayDocs = await _db.collection('payments')
          .where('createdAt', isGreaterThanOrEqualTo: startOfToday).get();
      var yesterdayDocs = await _db.collection('payments')
          .where('createdAt', isGreaterThanOrEqualTo: startOfYesterday)
          .where('createdAt', isLessThan: startOfToday).get();

      double todaySum = todayDocs.docs.fold(0.0, (acc, doc) => acc + (doc.data()['amount'] ?? 0).toDouble());
      double yesterdaySum = yesterdayDocs.docs.fold(0.0, (acc, doc) => acc + (doc.data()['amount'] ?? 0).toDouble());

      double diff = 0;
      String status = "STABLE";
      String message = "No change";

      if (yesterdaySum > 0) {
        diff = ((todaySum - yesterdaySum) / yesterdaySum) * 100;
        if (diff > 10) {
          status = "PEAK";
        } else if (diff < -10) {
          status = "DROPPING";
        }
        message = "${diff.abs().toStringAsFixed(0)}% ${diff >= 0 ? 'higher' : 'lower'} than yesterday";
      } else {
        status = todaySum > 0 ? "PEAK" : "STABLE";
        message = todaySum > 0 ? "New sales today" : "Stable since yesterday";
      }

      return {
        "status": status,
        "message": message,
        "diff": diff
      };
    });
  }

  Future<List<double>> getWeeklyRevenue() async {
    try {
      List<double> weeklyRevenue = List.filled(7, 0.0);
      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day - 6);
      var snapshot = await _db.collection('payments').where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo).get();
      for (var doc in snapshot.docs) {
        DateTime date = (doc.data()['createdAt'] as Timestamp).toDate();
        int diff = date.difference(sevenDaysAgo).inDays;
        if (diff >= 0 && diff < 7) weeklyRevenue[diff] += (doc.data()['amount'] ?? 0).toDouble();
      }
      return weeklyRevenue;
    } catch (e) { return List.filled(7, 0.0); }
  }

  Future<List<double>> getMonthlyRevenue() async {
    try {
      List<double> monthlyRevenue = List.filled(12, 0.0);
      DateTime now = DateTime.now();
      var snapshot = await _db.collection('payments').where('createdAt', isGreaterThanOrEqualTo: DateTime(now.year, 1, 1)).get();
      for (var doc in snapshot.docs) {
        DateTime date = (doc.data()['createdAt'] as Timestamp).toDate();
        if (date.year == now.year) monthlyRevenue[date.month - 1] += (doc.data()['amount'] ?? 0).toDouble();
      }
      return monthlyRevenue;
    } catch (e) { return List.filled(12, 0.0); }
  }

  Stream<List<double>> getMemberFlowStream() {
    DateTime now = DateTime.now();
    return _db.collection('checkins').where('timestamp', isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day)).snapshots().map((snapshot) {
      List<double> flow = List.filled(6, 0.0);
      for (var doc in snapshot.docs) {
        int index = (doc.data()['timestamp'] as Timestamp).toDate().hour ~/ 4;
        if (index >= 0 && index < 6) flow[index]++;
      }
      return flow;
    });
  }

  Stream<QuerySnapshot> getRecentCheckins() => _db.collection('checkins').orderBy('timestamp', descending: true).limit(10).snapshots();
  Stream<List<Map<String, dynamic>>> getUpcomingClassesStream() => _db.collection('classes').orderBy('time').snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  Stream<List<Map<String, dynamic>>> getEquipmentStatusStream() =>
      _db.collection('equipment').snapshots().map((snapshot) {
        final docs = snapshot.docs.map((d) => d.data()).toList();
        if (docs.isEmpty) {
          return <Map<String, dynamic>>[];
        }
        final hasAggregate = docs.any((e) => e.containsKey('total'));
        if (hasAggregate) {
          return docs;
        }
        final Map<String, Map<String, dynamic>> grouped = {};
        for (final item in docs) {
          final category = item['category'] ?? 'Khác';
          final status = item['status'] ?? 'Operational';
          grouped.putIfAbsent(category, () {
            return {'name': category, 'total': 0, 'operational': 0};
          });
          grouped[category]!['total'] =
              (grouped[category]!['total'] as int) + 1;
          if (status == 'Operational') {
            grouped[category]!['operational'] =
                (grouped[category]!['operational'] as int) + 1;
          }
        }
        return grouped.values.toList();
      });
}
