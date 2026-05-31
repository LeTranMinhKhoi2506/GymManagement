import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../app/route/routes.dart';

class PtScheduleScreen extends StatefulWidget {
  const PtScheduleScreen({super.key});

  @override
  State<PtScheduleScreen> createState() => _PtScheduleScreenState();
}

class _PtScheduleScreenState extends State<PtScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              const Text(
                "LỊCH DẠY",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                "${DateFormat('MMMM yyyy', 'vi_VN').format(selectedDate).toUpperCase()} • LỊCH TRÌNH CÁ NHÂN",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildHorizontalCalendar(),
              const SizedBox(height: 30),
              
              StreamBuilder<QuerySnapshot>(
                // Bỏ .orderBy('startTime') ở đây để tránh lỗi Index
                stream: FirebaseFirestore.instance
                    .collection('schedules')
                    .where('staffUid', isEqualTo: ptId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Không có ca dạy nào", style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  // Lọc theo ngày và Sắp xếp thủ công tại local
                  final dailySessions = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['startTime'] == null) return false;
                    final startTime = (data['startTime'] as Timestamp).toDate();
                    return DateUtils.isSameDay(startTime, selectedDate);
                  }).toList();

                  // Sắp xếp theo thời gian tăng dần
                  dailySessions.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                    final bTime = (b.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                    return aTime.compareTo(bTime);
                  });

                  if (dailySessions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Không có ca dạy nào trong ngày này", style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  return Column(
                    children: dailySessions.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      DateTime startTime = (data['startTime'] as Timestamp).toDate();
                      String status = (data['status'] ?? "pending").toUpperCase();
                      
                      String displayStatus = "SẮP TỚI";
                      if (status == "ONGOING") displayStatus = "ĐANG DẠY";
                      if (status == "COMPLETED") displayStatus = "HOÀN THÀNH";

                      return _buildTimelineSession(
                        time: DateFormat('HH:mm').format(startTime),
                        name: data['task'] ?? "Công việc",
                        category: "HUẤN LUYỆN",
                        status: displayStatus,
                        statusColor: _getStatusColor(status),
                        actionText: _getActionText(status),
                        isCurrent: status == "ONGOING",
                        sessionId: doc.id,
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              _buildQuoteSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "COMPLETED": return Colors.grey;
      case "ONGOING": return const Color(0xFFD0FD3E);
      case "PENDING": return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }

  String _getActionText(String status) {
    switch (status) {
      case "COMPLETED": return "XEM TÓM TẮT";
      case "ONGOING": return "TIẾP TỤC";
      default: return "BẮT ĐẦU";
    }
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildSafeAvatar(user?.photoURL ?? 'https://i.pravatar.cc/150?u=pt_marcus', 18),
            const SizedBox(width: 10),
            const Text("KINETIC", style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 18, fontWeight: FontWeight.bold)),
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
          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.white, size: radius),
        ),
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          DateTime date = startOfWeek.add(Duration(days: index));
          bool isSelected = DateUtils.isSameDay(date, selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDateItem(DateFormat('E', 'vi_VN').format(date).toUpperCase(), date.day.toString(), isSelected),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(date, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          ]
        ],
      ),
    );
  }

  Widget _buildTimelineSession({
    required String time,
    required String name,
    required String category,
    required String status,
    required Color statusColor,
    required String actionText,
    required bool isCurrent,
    required String sessionId,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Column(
              children: [
                Text(time, style: TextStyle(color: isCurrent ? const Color(0xFFD0FD3E) : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                Expanded(child: Container(width: 1, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(vertical: 5))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: isCurrent ? Border.all(color: const Color(0xFFD0FD3E).withOpacity(0.3), width: 1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(category, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: statusColor.withOpacity(0.3))),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(status, style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrent ? const Color(0xFFD0FD3E) : const Color(0xFF2C2C2E),
                            foregroundColor: isCurrent ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(actionText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 10),
          const Text(
            "\"Cơ thể con người là cỗ máy duy nhất hỏng hóc nếu không được sử dụng.\"",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          const Text("— GHI CHÚ HUẤN LUYỆN VIÊN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Align(alignment: Alignment.bottomRight, child: Icon(Icons.fitness_center, color: Colors.grey.withOpacity(0.2), size: 60)),
        ],
      ),
    );
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go(Routes.ptDashboard);
          if (index == 2) context.go(Routes.ptStudentManagement);
          if (index == 3) context.go(Routes.ptIncome);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "LỊCH DẠY"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "HỌC VIÊN"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "TÀI KHOẢN"),
        ],
      ),
    );
  }
}
