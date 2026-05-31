import 'package:flutter/material.dart';

class PtClassRegistrationScreen extends StatefulWidget {
  const PtClassRegistrationScreen({super.key});

  @override
  State<PtClassRegistrationScreen> createState() => _PtClassRegistrationScreenState();
}

class _PtClassRegistrationScreenState extends State<PtClassRegistrationScreen> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController _priceController = TextEditingController();

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.limeAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ĐĂNG KÝ MỞ LỚP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("THÔNG TIN LỚP HỌC", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 20),
            _buildInputField("Tên lớp học / Loại hình tập luyện", "VD: Yoga, Power Lift..."),
            const SizedBox(height: 25),
            const Text("KHUNG GIỜ DẠY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
            const Text("HỌC PHÍ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
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
                  suffixStyle: TextStyle(color: Colors.limeAccent, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logic đăng ký
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("XÁC NHẬN ĐĂNG KÝ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
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
          color: const Color(0xFF1E1E1E),
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
