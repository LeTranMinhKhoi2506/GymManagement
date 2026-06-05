import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../app/route/routes.dart';

class PtDashboardScreen extends StatefulWidget {
  const PtDashboardScreen({super.key});

  @override
  State<PtDashboardScreen> createState() => _PtDashboardScreenState();
}

class _PtDashboardScreenState extends State<PtDashboardScreen> {
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
              _buildOperationalProtocol(context, ptId),
              const SizedBox(height: 30),
              _buildSectionTitle("TRUNG TÂM QUẢN LÝ"),
              const SizedBox(height: 15),
              _buildMyScheduleCard(context, ptId),
              const SizedBox(height: 15),
              _buildHubSecondaryRow(context),
              const SizedBox(height: 15),
              _buildHubThirdRow(context),
              const SizedBox(height: 30),
              _buildSectionHeader("HOẠT ĐỘNG GẦN ĐÂY", () {}),
              const SizedBox(height: 15),
              _buildRecentActivityList(ptId),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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
                  color: Colors.black.withValues(alpha: 0.1),
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

  // Chức năng VẬN HÀNH: Vào ca / Hết ca (Tích hợp QR Chấm công) và Điểm danh học viên
  Widget _buildOperationalProtocol(BuildContext context, String ptId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pt_shifts')
          .where('ptId', isEqualTo: ptId)
          .where('endTime', isNull: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        bool checkedIn = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        String shiftId = checkedIn ? snapshot.data!.docs.first.id : '';

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _handleQRShiftCheck(context, ptId, checkedIn, shiftId),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: checkedIn ? const Color(0xFF1E3A1E) : const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(15),
                    border: checkedIn ? Border.all(color: Colors.greenAccent, width: 1.5) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner, 
                        color: checkedIn ? Colors.greenAccent : Colors.white, 
                        size: 20
                      ),
                      const SizedBox(width: 10),
                      Text(
                        checkedIn ? "HẾT CA" : "VÀO CA (QR)", 
                        style: TextStyle(
                          color: checkedIn ? Colors.greenAccent : Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                onTap: () => _showAttendanceBottomSheet(context, ptId),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_search_outlined, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 10),
                      Text("ĐIỂM DANH", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  // Mở Dialog quét QR chấm công Vào ca / Hết ca
  void _handleQRShiftCheck(BuildContext context, String ptId, bool isCheckedIn, String shiftId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => QRScannerDialog(
        title: isCheckedIn ? "QUÉT QR CHẤM CÔNG HẾT CA" : "QUÉT QR CHẤM CÔNG VÀO CA",
        subtitle: isCheckedIn ? "Hãy căn chỉnh mã QR hết ca của phòng tập vào khung hình" : "Hãy căn chỉnh mã QR vào ca của phòng tập vào khung hình",
        onSuccess: () async {
          if (isCheckedIn) {
            // Hết ca: cập nhật endTime
            await FirebaseFirestore.instance.collection('pt_shifts').doc(shiftId).update({
              'endTime': FieldValue.serverTimestamp(),
            });
            // Thêm vào hoạt động
            await FirebaseFirestore.instance.collection('pt_activities').add({
              'ptId': ptId,
              'type': 'session',
              'title': 'Hết ca làm việc',
              'subtitle': 'Đã hoàn thành ca làm việc lúc ${DateFormat('HH:mm').format(DateTime.now())}',
              'timestamp': FieldValue.serverTimestamp(),
            });
          } else {
            // Vào ca: tạo doc mới
            await FirebaseFirestore.instance.collection('pt_shifts').add({
              'ptId': ptId,
              'startTime': FieldValue.serverTimestamp(),
              'endTime': null,
              'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
              'type': 'QR_CHECK_IN',
            });
            // Thêm vào hoạt động
            await FirebaseFirestore.instance.collection('pt_activities').add({
              'ptId': ptId,
              'type': 'session',
              'title': 'Vào ca làm việc',
              'subtitle': 'Bắt đầu ca làm việc bằng QR lúc ${DateFormat('HH:mm').format(DateTime.now())}',
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        },
      ),
    );
  }

  // Mở Bottom Sheet danh sách học viên để điểm danh nhanh
  void _showAttendanceBottomSheet(BuildContext context, String ptId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ĐIỂM DANH HỌC VIÊN",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Chọn học viên dưới đây để quét mã QR điểm danh buổi tập",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .where('ptId', isEqualTo: ptId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu học viên", style: TextStyle(color: Colors.red)));
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Chưa có học viên nào để điểm danh", style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            var data = doc.data() as Map<String, dynamic>;
                            String studentName = data['name'] ?? "Học viên";
                            String goal = data['goal'] ?? "CHƯA XÁC ĐỊNH";

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: _buildSafeAvatar(data['photoUrl'] ?? 'https://i.pravatar.cc/150?u=${doc.id}', 24),
                              title: Text(studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              subtitle: Text("Mục tiêu: $goal", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              trailing: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context); // Đóng Bottom Sheet trước
                                  _handleStudentQRCheck(context, ptId, studentName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD0FD3E),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.qr_code_scanner, size: 16),
                                label: const Text("QUÉT QR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Quét QR điểm danh cho học viên
  void _handleStudentQRCheck(BuildContext context, String ptId, String studentName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => QRScannerDialog(
        title: "QUÉT MÃ QR HỌC VIÊN",
        subtitle: "Đặt mã QR của học viên $studentName vào giữa khung hình để điểm danh",
        onSuccess: () async {
          // Thêm hoạt động điểm danh thành công
          await FirebaseFirestore.instance.collection('pt_activities').add({
            'ptId': ptId,
            'type': 'booking',
            'title': 'Điểm danh học viên thành công',
            'subtitle': 'Học viên $studentName đã có mặt đúng giờ',
            'timestamp': FieldValue.serverTimestamp(),
          });
        },
      ),
    );
  }

  Widget _buildMyScheduleCard(BuildContext context, String ptId) {
    return GestureDetector(
      onTap: () => context.go(Routes.ptSchedule),
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
                        .collection('schedules')
                        .where('staffUid', isEqualTo: ptId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String nextSessionInfo = "Không có ca dạy sắp tới";
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        // Tìm ca sắp tới ở local
                        final now = DateTime.now();
                        var upcomingDocs = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          if (data['startTime'] == null) return false;
                          DateTime startTime = (data['startTime'] as Timestamp).toDate();
                          String status = data['status'] ?? 'pending';
                          return startTime.isAfter(now) && status != 'completed';
                        }).toList();

                        if (upcomingDocs.isNotEmpty) {
                          upcomingDocs.sort((a, b) {
                            var aTime = (a.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                            var bTime = (b.data() as Map<String, dynamic>)['startTime'] as Timestamp;
                            return aTime.compareTo(bTime);
                          });

                          var data = upcomingDocs.first.data() as Map<String, dynamic>;
                          DateTime time = (data['startTime'] as Timestamp).toDate();
                          nextSessionInfo = "Ca tiếp theo: ${DateFormat('HH:mm').format(time)} - ${data['task'] ?? 'Huấn luyện'}";
                        }
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
            onTap: () => context.go(Routes.ptStudentManagement),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildHubCard(
            icon: Icons.bar_chart,
            title: "Báo cáo\nThu nhập",
            subtitle: "CHI TIẾT THÁNG",
            iconColor: Colors.yellowAccent,
            onTap: () => context.go(Routes.ptIncome),
          ),
        ),
      ],
    );
  }

  // Dòng thẻ quản lý thứ ba: Nút điều hướng đến "ĐĂNG KÝ MỞ LỚP" (Class registration) cực đẹp
  Widget _buildHubThirdRow(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.ptClassRegistration),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add_task, color: Color(0xFFD0FD3E), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Đăng ký mở lớp học mới",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "ĐĂNG KÝ LỊCH VÀ KHUNG GIỜ GIẢNG DẠY",
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Chưa có hoạt động nào gần đây", style: TextStyle(color: Colors.grey)),
            ),
          );
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
              DateTime time = data['timestamp'] != null 
                  ? (data['timestamp'] as Timestamp).toDate() 
                  : DateTime.now();
              
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

}

// Widget Dialog quét mã QR Chấm công với hiệu ứng quét camera cực chuyên nghiệp và mượt mà
class QRScannerDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onSuccess;

  const QRScannerDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSuccess,
  });

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _lineAnimationController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Giả lập quét QR thành công sau 2 giây
    Timer(const Duration(seconds: 2), () async {
      if (mounted) {
        setState(() {
          _isSuccess = true;
        });
        _lineAnimationController.stop();
        // Thực thi tác vụ xử lý DB
        await widget.onSuccess();
        // Đóng Dialog sau 1 giây hiển thị thành công
        Timer(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            
            // Khung hình giả lập máy quét camera
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Giả lập background Camera
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      height: double.infinity,
                      child: Opacity(
                        opacity: 0.3,
                        child: Center(
                          child: Icon(
                            _isSuccess ? Icons.qr_code_2 : Icons.camera_alt_outlined, 
                            color: Colors.white30, 
                            size: 150
                          ),
                        ),
                      ),
                    ),
                    
                    // Khung quét QR phát sáng
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isSuccess ? Colors.greenAccent : const Color(0xFFD0FD3E), 
                            width: 2
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // Góc quét QR phong cách khoa học viễn tưởng
                    ..._buildCornerBorders(),

                    // Dòng quét chuyển động quét
                    if (!_isSuccess)
                      AnimatedBuilder(
                        animation: _lineAnimationController,
                        builder: (context, child) {
                          // Chuyển động từ 10% đến 90% chiều cao của khung
                          double offset = 220 * _lineAnimationController.value;
                          return Positioned(
                            top: (MediaQuery.of(context).size.width - 50 - 220) / 2 + offset - 10, // Cân chỉnh dòng quét tương đối
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 220,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD0FD3E),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD0FD3E).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                ),
                              ),
                            ),
                          );
                        }
                      ),

                    // Hiển thị trạng thái thành công
                    if (_isSuccess)
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check, 
                            color: Colors.black, 
                            size: 45,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Nút hủy/Đóng
            if (!_isSuccess)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text("HỦY BỎ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerBorders() {
    const double length = 20;
    const double thickness = 4;
    final color = _isSuccess ? Colors.greenAccent : const Color(0xFFD0FD3E);

    return [
      // Top Left Corner
      Positioned(
        top: 25,
        left: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        top: 25,
        left: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Top Right Corner
      Positioned(
        top: 25,
        right: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        top: 25,
        right: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Bottom Left Corner
      Positioned(
        bottom: 25,
        left: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        bottom: 25,
        left: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
      // Bottom Right Corner
      Positioned(
        bottom: 25,
        right: 25,
        child: Container(width: length, height: thickness, color: color),
      ),
      Positioned(
        bottom: 25,
        right: 25,
        child: Container(width: thickness, height: length, color: color),
      ),
    ];
  }
}
