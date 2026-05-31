import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../app/route/routes.dart';

class PtDashboardScreen extends StatelessWidget {
  const PtDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildGreeting(),
              const SizedBox(height: 30),
              
              // Stats Row with Real Data
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pt_sessions')
                    .where('ptId', isEqualTo: ptId)
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
                    .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
                    .snapshots(),
                builder: (context, sessionSnapshot) {
                  int sessionsToday = sessionSnapshot.hasData ? sessionSnapshot.data!.docs.length : 0;
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .where('ptId', isEqualTo: ptId)
                        .snapshots(),
                    builder: (context, studentSnapshot) {
                      int activeStudents = studentSnapshot.hasData ? studentSnapshot.data!.docs.length : 0;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _buildSmallStatCard(
                              icon: Icons.bolt,
                              value: sessionsToday.toString(),
                              label: "CA DẠY HÔM NAY",
                              iconColor: const Color(0xFFD0FD3E),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSmallStatCard(
                              icon: Icons.people_outline,
                              value: activeStudents.toString(),
                              label: "HỌC VIÊN ĐANG THEO",
                              iconColor: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      );
                    }
                  );
                }
              ),
              
              const SizedBox(height: 15),
              
              // Earnings Card with Real Data
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pt_sessions')
                    .where('ptId', isEqualTo: ptId)
                    .where('status', isEqualTo: 'HOÀN THÀNH')
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
                    .snapshots(),
                builder: (context, snapshot) {
                  double todayEarnings = 0;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      todayEarnings += (doc.data() as Map<String, dynamic>)['amount'] ?? 0.0;
                    }
                  }
                  return _buildEarningsCard(todayEarnings);
                },
              ),

              const SizedBox(height: 30),
              _buildSectionTitle("QUY TRÌNH VẬN HÀNH"),
              const SizedBox(height: 15),
              _buildOperationalProtocol(),
              const SizedBox(height: 30),
              _buildSectionTitle("TRUNG TÂM QUẢN LÝ"),
              const SizedBox(height: 15),
              _buildMyScheduleCard(context, ptId),
              const SizedBox(height: 15),
              _buildHubSecondaryRow(context),
              const SizedBox(height: 30),
              _buildSectionHeader("HOẠT ĐỘNG GẦN ĐÂY", () {}),
              const SizedBox(height: 15),
              _buildRecentActivityList(ptId),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildSafeAvatar(user?.photoURL ?? 'https://i.pravatar.cc/150?u=pt_marcus', 18),
            const SizedBox(width: 10),
            const Text(
              "KINETIC",
              style: TextStyle(
                color: Color(0xFFD0FD3E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications_none, color: Colors.white, size: 28),
      ],
    );
  }

  Widget _buildSafeAvatar(String url, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[900],
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, color: Colors.white, size: radius);
          },
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "Huấn luyện viên";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
            children: [
              const TextSpan(text: "Xin chào,\n", style: TextStyle(color: Colors.white)),
              TextSpan(text: name, style: const TextStyle(color: Color(0xFFD0FD3E))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Hệ thống đã sẵn sàng. Chúc bạn một ngày làm việc hiệu quả.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({required IconData icon, required String value, required String label, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(double earnings) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD0FD3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.black, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "HÔM NAY",
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            formatter.format(earnings),
            style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            "THU NHẬP ĐÃ HOÀN THÀNH",
            style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
    );
  }

  Widget _buildOperationalProtocol() {
    return Row(
      children: [
        Expanded(
          child: _buildProtocolButton(Icons.timer_outlined, "VÀO CA", Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildProtocolButton(Icons.person_search_outlined, "ĐIỂM DANH", Colors.orangeAccent),
        ),
      ],
    );
  }

  Widget _buildProtocolButton(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMyScheduleCard(BuildContext context, String ptId) {
    return GestureDetector(
      onTap: () => context.push(Routes.ptSchedule),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pt_sessions')
                        .where('ptId', isEqualTo: ptId)
                        .where('status', isEqualTo: 'SẮP TỚI')
                        .orderBy('timestamp')
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String nextSessionInfo = "Không có ca dạy sắp tới";
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                        DateTime time = (data['timestamp'] as Timestamp).toDate();
                        nextSessionInfo = "Ca tiếp theo: ${DateFormat('HH:mm').format(time)} - ${data['studentName']}";
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Lịch dạy của tôi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(nextSessionInfo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      );
                    }
                  ),
                ),
                const Icon(Icons.calendar_month, color: Color(0xFFD0FD3E), size: 30),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildAvatarStack(ptId),
                const SizedBox(width: 10),
                const Text("Học viên sắp tới", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(String ptId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('ptId', isEqualTo: ptId)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(width: 20);
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: snapshot.data!.docs.asMap().entries.map((entry) {
            int index = entry.key;
            var data = entry.value.data() as Map<String, dynamic>;
            return Align(
              widthFactor: 0.6,
              child: _buildSafeAvatar(data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=student$index', 14),
            );
          }).toList(),
        );
      }
    );
  }

  Widget _buildHubSecondaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildHubCard(
            icon: Icons.person_search,
            title: "Danh sách\nHọc viên",
            subtitle: "XEM & QUẢN LÝ",
            iconColor: Colors.orangeAccent,
            onTap: () => context.push(Routes.ptStudentManagement),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildHubCard(
            icon: Icons.bar_chart,
            title: "Báo cáo\nThu nhập",
            subtitle: "CHI TIẾT THÁNG",
            iconColor: Colors.yellowAccent,
            onTap: () => context.push(Routes.ptIncome),
          ),
        ),
      ],
    );
  }

  Widget _buildHubCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            "XEM TẤT CẢ",
            style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(String ptId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pt_activities')
          .where('ptId', isEqualTo: ptId)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Chưa có hoạt động nào", style: TextStyle(color: Colors.grey)));
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime time = (data['timestamp'] as Timestamp).toDate();
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getActivityIcon(data['type']),
                    color: _getActivityColor(data['type']),
                    size: 20
                  ),
                ),
                title: Text(data['title'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(data['subtitle'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Text(DateFormat('HH:mm').format(time), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              );
            },
          ),
        );
      }
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'note': return Icons.edit_note;
      case 'session': return Icons.check_circle_outline;
      case 'booking': return Icons.assignment_turned_in_outlined;
      default: return Icons.notifications_none;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'note': return const Color(0xFFD0FD3E);
      case 'session': return Colors.orangeAccent;
      case 'booking': return Colors.yellowAccent;
      default: return Colors.white;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0FD3E),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          if (index == 1) context.go(Routes.ptSchedule);
          if (index == 2) context.go(Routes.ptStudentManagement);
          if (index == 3) context.go(Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "LỊCH DẠY"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "HỌC VIÊN"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "TÀI KHOẢN"),
        ],
      ),
    );
  }
}
