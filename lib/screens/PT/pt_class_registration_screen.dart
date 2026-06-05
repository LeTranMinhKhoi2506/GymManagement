import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PtClassRegistrationScreen extends StatefulWidget {
  const PtClassRegistrationScreen({super.key});

  @override
  State<PtClassRegistrationScreen> createState() => _PtClassRegistrationScreenState();
}

class _PtClassRegistrationScreenState extends State<PtClassRegistrationScreen> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD0FD3E),
              onPrimary: Colors.black,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  // Chuyển TimeOfDay sang số phút tính từ 00:00 để so sánh toán học
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _registerClass() async {
    final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    if (_classNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    // 1. Khoá nghiệp vụ: Giờ kết thúc phải lớn hơn giờ bắt đầu
    int startMin = _timeToMinutes(startTime!);
    int endMin = _timeToMinutes(endTime!);
    if (endMin <= startMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Lỗi nghiệp vụ: Giờ kết thúc phải lớn hơn giờ bắt đầu!"),
        ),
      );
      return;
    }

    // 2. Khoá nghiệp vụ: Mỗi ca dạy tối thiểu kéo dài 30 phút
    if (endMin - startMin < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Lỗi nghiệp vụ: Mỗi lớp học phải kéo dài tối thiểu 30 phút!"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Khoá nghiệp vụ: Không trùng lặp khung giờ dạy với các lớp đã đăng ký
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pt_classes')
          .where('ptId', isEqualTo: ptId)
          .where('status', isEqualTo: 'active')
          .get();

      bool isOverlapping = false;
      String overlappingClassName = "";
      String overlappingTimeStr = "";

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        String existStartStr = data['startTime'] ?? "";
        String existEndStr = data['endTime'] ?? "";

        var startParts = existStartStr.split(":");
        var endParts = existEndStr.split(":");

        if (startParts.length == 2 && endParts.length == 2) {
          int existStart = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          int existEnd = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

          // Công thức kiểm tra trùng lặp khoảng thời gian: (StartA < EndB) và (StartB < EndA)
          if (startMin < existEnd && existStart < endMin) {
            isOverlapping = true;
            overlappingClassName = data['className'] ?? "Lớp khác";
            overlappingTimeStr = "$existStartStr - $existEndStr";
            break;
          }
        }
      }

      if (isOverlapping) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: const Text("TRÙNG LỊCH ĐĂNG KÝ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              content: Text(
                "Khung giờ chọn trùng lặp với lớp đã mở:\n\n• Lớp: $overlappingClassName\n• Giờ dạy: $overlappingTimeStr\n\nVui lòng điều chỉnh lại giờ học khác.",
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ĐỒNG Ý", style: TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Đủ điều kiện đăng ký
      String startStr = "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}";
      String endStr = "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance.collection('pt_classes').add({
        'ptId': ptId,
        'className': _classNameController.text.trim(),
        'startTime': startStr,
        'endTime': endStr,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Tạo hoạt động ghi nhận
      await FirebaseFirestore.instance.collection('pt_activities').add({
        'ptId': ptId,
        'type': 'booking',
        'title': 'Đăng ký mở lớp học mới',
        'subtitle': 'Lớp: ${_classNameController.text.trim()} ($startStr - $endStr)',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFD0FD3E),
            content: Text("Đăng ký lớp học mới thành công!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        );
        // Clear inputs
        _classNameController.clear();
        _priceController.clear();
        setState(() {
          startTime = null;
          endTime = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng ký: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Xóa lớp học đã mở
  void _deleteClass(String classId, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("HỦY MỞ LỚP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Bạn chắc chắn muốn hủy đăng ký lớp học '$className' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("QUAY LẠI", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('pt_classes').doc(classId).update({
                'status': 'cancelled',
              });
              messenger.showSnackBar(
                const SnackBar(content: Text("Đã hủy lớp học thành công")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("XÁC NHẬN HỦY", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String ptId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ĐĂNG KÝ MỞ LỚP",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("THÔNG TIN LỚP HỌC MỚI",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _classNameController,
              label: "Tên lớp học / Thể loại huấn luyện",
              hint: "VD: Yoga Core, Powerlifting, HIIT Burn...",
            ),
            const SizedBox(height: 25),
            const Text("KHUNG GIỜ DẠY ĐĂNG KÝ",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    "Bắt đầu",
                    startTime?.format(context) ?? "--:--",
                    () => _selectTime(context, true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTimePicker(
                    "Kết thúc",
                    endTime?.format(context) ?? "--:--",
                    () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text("HỌC PHÍ HUẤN LUYỆN (THÁNG)",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "Nhập số tiền học phí/tháng...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  suffixText: "VNĐ",
                  suffixStyle: TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0FD3E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)))
                    : const Text("XÁC NHẬN ĐĂNG KÝ LỚP MỚI",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            
            // Danh sách các lớp học đã mở
            const SizedBox(height: 45),
            const Text("DANH SÁCH LỚP HỌC CỦA TÔI",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
            const SizedBox(height: 20),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pt_classes')
                  .where('ptId', isEqualTo: ptId)
                  .where('status', isEqualTo: 'active')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Lỗi tải lớp học", style: TextStyle(color: Colors.red)));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text("Bạn chưa có lớp học nào được đăng ký", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String className = data['className'] ?? "Lớp học";
                    String timeRange = "${data['startTime'] ?? '--'} - ${data['endTime'] ?? '--'}";
                    double price = (data['price'] as num?)?.toDouble() ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_today, color: Color(0xFFD0FD3E), size: 20),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(className, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.grey, size: 12),
                                    const SizedBox(width: 5),
                                    Text(timeRange, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.sell, color: Colors.grey, size: 12),
                                    const SizedBox(width: 5),
                                    Text(formatter.format(price), style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteClass(doc.id, className),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 5),
            Text(time, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
