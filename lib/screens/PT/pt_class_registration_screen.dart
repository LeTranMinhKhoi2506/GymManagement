import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _registerClass() async {
    if (_classNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('pt_classes').add({
        'ptId': user?.uid ?? 'anonymous',
        'className': _classNameController.text.trim(),
        'startTime': "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}",
        'endTime': "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}",
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký lớp học thành công!")),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text("THÔNG TIN LỚP HỌC",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _classNameController,
              label: "Tên lớp học / Loại hình tập luyện",
              hint: "VD: Yoga, Power Lift...",
            ),
            const SizedBox(height: 25),
            const Text("KHUNG GIỜ DẠY",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
            const Text("HỌC PHÍ",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
                  hintText: "Giá tiền thuê 1 tháng",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  suffixText: "VNĐ",
                  suffixStyle: TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
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
                    : const Text("XÁC NHẬN ĐĂNG KÝ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
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
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
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
