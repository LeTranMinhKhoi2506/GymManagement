import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/schedule_controller.dart';
import '../../../controllers/staff_controller.dart';
import '../../../data/models/user_model.dart';

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  UserModel? selectedStaff;
  final taskController = TextEditingController();
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffController = Provider.of<StaffController>(context, listen: false);
    final scheduleController = Provider.of<ScheduleController>(context, listen: false);

    return AlertDialog(
      title: const Text("Thêm lịch làm việc mới"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<UserModel>>(
              stream: staffController.staffStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Không có nhân viên nào để chọn", style: TextStyle(color: Colors.red));
                }
                return DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: "Chọn nhân viên",
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text("${s.fullName} (${s.position ?? 'N/A'})"),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedStaff = val;
                    });
                  },
                );
              }
            ),
            const SizedBox(height: 16),
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: "Tên công việc / Lớp học",
                border: OutlineInputBorder(),
                hintText: "VD: Lớp Yoga, Trực quầy lễ tân...",
              ),
            ),
            const SizedBox(height: 16),
            const Text("Thời gian làm việc:", style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Bắt đầu: ${DateFormat('HH:mm dd/MM').format(selectedStartTime)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedStartTime,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedStartTime));
                  if (time != null) {
                    setState(() {
                      selectedStartTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      if (selectedEndTime.isBefore(selectedStartTime)) {
                        selectedEndTime = selectedStartTime.add(const Duration(hours: 1));
                      }
                    });
                  }
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Kết thúc: ${DateFormat('HH:mm dd/MM').format(selectedEndTime)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedEndTime,
                  firstDate: selectedStartTime,
                  lastDate: selectedStartTime.add(const Duration(days: 365)),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedEndTime));
                  if (time != null) {
                    setState(() {
                      selectedEndTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
          onPressed: () async {
            if (selectedStaff == null) {
              _showError("Vui lòng chọn nhân viên");
              return;
            }

            if (selectedStaff!.status != 'active') {
              _showError("Nhân viên này hiện đang không hoạt động (Trạng thái: ${selectedStaff!.status})");
              return;
            }

            if (selectedStaff!.position == 'Resigned' || selectedStaff!.position == 'On Leave') {
              _showError("Nhân viên đang nghỉ phép hoặc đã nghỉ việc");
              return;
            }

            final taskName = taskController.text.trim();
            if (taskName.isEmpty) {
              _showError("Vui lòng nhập tên công việc");
              return;
            }

            if ((taskName.toLowerCase().contains("lớp") || taskName.toLowerCase().contains("yoga") || taskName.toLowerCase().contains("hiit")) && 
                selectedStaff!.position != "Trainer") {
              _showError("Chỉ HLV (Trainer) mới được phân công dạy lớp");
              return;
            }

            if (selectedEndTime.isBefore(selectedStartTime) || selectedEndTime.isAtSameMomentAs(selectedStartTime)) {
              _showError("Thời gian kết thúc phải sau thời gian bắt đầu");
              return;
            }

            if (selectedStartTime.hour < 5 || selectedEndTime.hour > 22 || (selectedEndTime.hour == 22 && selectedEndTime.minute > 0)) {
              _showError("Thời gian ca làm việc phải nằm trong giờ hoạt động của Gym (05:00 - 22:00)");
              return;
            }

            final allSchedules = await scheduleController.todaySchedulesStream.first; 
            final staffSchedules = allSchedules.where((s) => s.staffUid == selectedStaff!.uid).toList();

            double totalHours = selectedEndTime.difference(selectedStartTime).inMinutes / 60.0;
            for (var s in staffSchedules) {
              totalHours += s.endTime.difference(s.startTime).inMinutes / 60.0;
            }
            if (totalHours > 12) {
              _showError("Nhân viên không được làm quá 12 giờ trong một ngày (Hiện tại: ${totalHours.toStringAsFixed(1)}h)");
              return;
            }

            if (staffSchedules.length >= 4) {
              _showError("Nhân viên không được làm quá 4 ca trong một ngày");
              return;
            }

            for (var s in staffSchedules) {
              if ((selectedStartTime.isBefore(s.endTime) && selectedEndTime.isAfter(s.startTime))) {
                _showError("Thời gian ca làm mới bị trùng với ca đã có: ${DateFormat('HH:mm').format(s.startTime)} - ${DateFormat('HH:mm').format(s.endTime)}");
                return;
              }

              int gapBefore = selectedStartTime.difference(s.endTime).inMinutes.abs();
              int gapAfter = s.startTime.difference(selectedEndTime).inMinutes.abs();
              
              if (gapBefore < 15 && selectedStartTime.isAfter(s.endTime)) {
                 _showError("Phải có ít nhất 15 phút nghỉ giữa các ca làm");
                 return;
              }
              if (gapAfter < 15 && s.startTime.isAfter(selectedEndTime)) {
                 _showError("Phải có ít nhất 15 phút nghỉ giữa các ca làm");
                 return;
              }
            }

            try {
              await scheduleController.addSchedule(
                staffUid: selectedStaff!.uid,
                staffName: selectedStaff!.fullName,
                task: taskName,
                startTime: selectedStartTime,
                endTime: selectedEndTime,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thêm lịch thành công"), backgroundColor: Colors.green),
                );
              }
            } catch (e) {
              if (context.mounted) _showError("Lỗi khi thêm lịch: $e");
            }
          },
          child: const Text("Lưu lịch làm"),
        ),
      ],
    );
  }
}
