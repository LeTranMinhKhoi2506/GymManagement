import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../app/route/routes.dart';
import '../../controllers/auth_controller.dart';

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
                stream: FirebaseFirestore.instance
                    .collection('schedules')
                    .where('staffUid', isEqualTo: ptId)
                    .snapshots(),
                builder: (context, schedulesSnapshot) {
                  if (schedulesSnapshot.hasError) {
                    return Center(child: Text("Lỗi: ${schedulesSnapshot.error}", style: const TextStyle(color: Colors.red)));
                  }
                  if (schedulesSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                  }

                  // 1. Lọc schedules của ngày được chọn
                  final dailySessions = schedulesSnapshot.data?.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['startTime'] == null) return false;
                    final startTime = (data['startTime'] as Timestamp).toDate();
                    return DateUtils.isSameDay(startTime, selectedDate);
                  }).toList() ?? [];

                  final List<Map<String, dynamic>> combinedList = [];

                  for (var doc in dailySessions) {
                    final data = doc.data() as Map<String, dynamic>;
                    final classId = data['classId']?.toString();
                    combinedList.add({
                      'id': doc.id,
                      'isClassTemplate': false,
                      'task': data['task'] ?? "Công việc",
                      'startTime': data['startTime'] as Timestamp,
                      'endTime': data['endTime'] as Timestamp,
                      'status': data['status'] ?? "pending",
                      'category': classId != null ? "LỚP PT" : "CÁ NHÂN",
                      'fullData': data,
                    });
                  }

                  if (combinedList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Không có lịch trình nào trong ngày này", style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  combinedList.sort((a, b) {
                    final aTime = a['startTime'] as Timestamp;
                    final bTime = b['startTime'] as Timestamp;
                    return aTime.compareTo(bTime);
                  });

                  return Column(
                    children: combinedList.map((item) {
                      final startTime = (item['startTime'] as Timestamp).toDate();
                      final status = (item['status'] as String).toUpperCase();
                      final isClassTemplate = item['isClassTemplate'] as bool;
                      
                      String displayStatus = "SẮP TỚI";
                      if (status == "ONGOING") displayStatus = "ĐANG DẠY";
                      if (status == "COMPLETED") displayStatus = "HOÀN THÀNH";

                      return _buildTimelineSession(
                        time: DateFormat('HH:mm').format(startTime),
                        name: item['task'] ?? "Công việc",
                        category: item['category'] ?? "HUẤN LUYỆN",
                        status: displayStatus,
                        rawStatus: status,
                        statusColor: _getStatusColor(status),
                        actionText: _getActionText(status),
                        isCurrent: status == "ONGOING",
                        sessionId: item['id'],
                        fullData: {
                          ...item['fullData'] as Map<String, dynamic>,
                          'isClassTemplate': isClassTemplate,
                          'targetStartTime': item['startTime'],
                          'targetEndTime': item['endTime'],
                        },
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
        Row(
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 26),
              onPressed: () async {
                await context.read<AuthController>().signOut();
                if (context.mounted) {
                  context.go(Routes.login);
                }
              },
            ),
          ],
        ),
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
    required String rawStatus,
    required Color statusColor,
    required String actionText,
    required bool isCurrent,
    required String sessionId,
    required Map<String, dynamic> fullData,
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
                Expanded(child: Container(width: 1, color: Colors.grey.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(vertical: 5))),
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
                border: isCurrent ? Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.3), width: 1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name, 
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(category, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                          onPressed: () => _handleSessionAction(sessionId, rawStatus, name, fullData),
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
                      GestureDetector(
                        onTap: () => _showSessionSummary(name, fullData),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                        ),
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

  // Xử lý các nút bấm Bắt đầu / Tiếp tục / Xem tóm tắt
  void _handleSessionAction(String sessionId, String status, String studentName, Map<String, dynamic> data) async {
    final messenger = ScaffoldMessenger.of(context);
    final cleanStudentName = studentName.replaceFirst("Huấn luyện học viên ", "");
    if (status == "PENDING") {
      try {
        await FirebaseFirestore.instance.collection('schedules').doc(sessionId).update({
          'status': 'ongoing',
        });
        await FirebaseFirestore.instance.collection('pt_activities').add({
          'ptId': ptId,
          'type': 'session',
          'title': 'Bắt đầu ca dạy',
          'subtitle': 'Đang huấn luyện học viên $cleanStudentName',
          'timestamp': FieldValue.serverTimestamp(),
        });
        messenger.showSnackBar(
          SnackBar(content: Text("Đã bắt đầu ca dạy học viên $cleanStudentName!")),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text("Lỗi bắt đầu ca dạy: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } else if (status == "ONGOING") {
      _showTrainingJournalBottomSheet(sessionId, cleanStudentName);
    } else if (status == "COMPLETED") {
      _showSessionSummary(cleanStudentName, data);
    }
  }

  // Bottom Sheet ghi nhật ký tập luyện & Hoàn thành ca dạy
  void _showTrainingJournalBottomSheet(String sessionId, String studentName) {
    final TextEditingController focusController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "NHẬT KÝ HUẤN LUYỆN: $studentName",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Trọng tâm buổi tập
              const Text("TRỌNG TÂM BUỔI TẬP", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: focusController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "VD: Squat & Đùi sau, Cardio nhẹ...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Ghi chú buổi tập của PT
              const Text("GHI CHÚ CHI TIẾT CỦA PT", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: notesController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Thể trạng học viên tốt, nâng tạ Squat 80kg hoàn thành 4 hiệp, chú ý sửa tư thế gối...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Nút hoàn thành ca dạy nhận 30k hoa hồng
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    String focus = focusController.text.trim();
                    String notes = notesController.text.trim();
                    if (focus.isEmpty || notes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vui lòng nhập đầy đủ trọng tâm và ghi chú ca dạy")),
                      );
                      return;
                    }

                    // 1. Cập nhật schedules sang completed kèm ghi chú
                    await FirebaseFirestore.instance.collection('schedules').doc(sessionId).update({
                      'status': 'completed',
                      'focus': focus,
                      'notes': notes,
                      'commission': 30000.0,
                    });

                    // 2. Tạo bản ghi doanh thu pt_sessions
                    await FirebaseFirestore.instance.collection('pt_sessions').add({
                      'ptId': ptId,
                      'studentName': studentName,
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': 'HOÀN THÀNH',
                      'amount': 30000.0, // Hoa hồng 30,000₫
                    });

                    // 3. Tạo bản ghi thù lao pt_payouts
                    await FirebaseFirestore.instance.collection('pt_payouts').add({
                      'ptId': ptId,
                      'amount': 30000.0,
                      'timestamp': FieldValue.serverTimestamp(),
                      'title': 'Hoa hồng ca dạy: $studentName',
                      'type': 'session',
                      'method': 'Chuyển khoản',
                      'status': 'HOÀN THÀNH',
                    });

                    // 4. Tạo hoạt động pt_activities
                    await FirebaseFirestore.instance.collection('pt_activities').add({
                      'ptId': ptId,
                      'type': 'session',
                      'title': 'Đã dạy xong ca',
                      'subtitle': 'Hoàn thành ca dạy của học viên $studentName. Nhận hoa hồng +30,000₫.',
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // 5. Lưu thêm vào pt_journals lịch sử buổi tập của học viên
                    await FirebaseFirestore.instance.collection('pt_journals').add({
                      'scheduleId': sessionId,
                      'ptId': ptId,
                      'studentName': studentName,
                      'focus': focus,
                      'notes': notes,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFD0FD3E),
                          content: Text(
                            "Chúc mừng! Ca dạy hoàn thành. Nhận thù lao +30,000₫ hoa hồng.",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "HOÀN THÀNH CA DẠY (+30,000₫)", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  // Xem tóm tắt ca dạy đã hoàn thành
  void _showSessionSummary(String studentName, Map<String, dynamic> data) {
    final cleanStudentName = studentName.replaceFirst("Huấn luyện học viên ", "");
    String focus = data['focus'] ?? "Chưa ghi chép";
    String notes = data['notes'] ?? "Chưa ghi chép";
    double commission = (data['commission'] as num?)?.toDouble() ?? 30000.0;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TÓM TẮT CA DẠY", style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(cleanStudentName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              const Text("TRỌNG TÂM TẬP LUYỆN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(focus, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 15),

              const Text("NHẬT KÝ PT GHI CHÚ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(notes, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 15),

              const Divider(color: Colors.white10),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("THÙ LAO HOA HỒNG", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(formatter.format(commission), style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
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
          Align(alignment: Alignment.bottomRight, child: Icon(Icons.fitness_center, color: Colors.grey.withValues(alpha: 0.2), size: 60)),
        ],
      ),
    );
  }

}
