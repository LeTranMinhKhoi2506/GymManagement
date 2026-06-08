import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:intl/intl.dart';
import '../../../utils/file_saver/file_saver.dart';
import '../../../data/models/schedule_model.dart';
import '../../../controllers/schedule_controller.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../../common/widgets/admin_schedule_widgets/quick_check_in_panel.dart';
import '../../../common/widgets/admin_schedule_widgets/live_activity_panel.dart';
import '../../../common/widgets/admin_schedule_widgets/calendar_view.dart';
import '../../../common/widgets/admin_schedule_widgets/add_schedule_dialog.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final TextEditingController _checkInController = TextEditingController();

  @override
  void dispose() {
    _checkInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ScheduleController>(context);

    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi vận hành: ${controller.errorMessage!}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          controller.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const SidebarWidget(),
          Expanded(
            child: Column(
              children: [
                const HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(context, controller),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  QuickCheckInPanel(controller: _checkInController),
                                  const SizedBox(height: 32),
                                  const LiveActivityPanel(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            const Expanded(
                              flex: 8,
                              child: CalendarView(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chức năng QR Code sẽ được cập nhật sau")),
          );
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, ScheduleController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VẬN HÀNH",
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Lịch làm việc & Check-in",
              style: TextStyle(
                color: Color(0xFF0A192F),
                fontWeight: FontWeight.w900,
                fontSize: 32,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _exportWorkLog(controller),
              icon: const Icon(Icons.file_download, size: 18),
              label: const Text("Xuất nhật ký"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A192F),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Phiên mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportWorkLog(ScheduleController controller) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang trích xuất nhật ký làm việc...'),
          backgroundColor: Colors.blueAccent,
          duration: Duration(seconds: 1),
        ),
      );

      final List<ScheduleModel> schedules = await controller.schedulesStream.first;

      final excel = Excel.createExcel();
      final Sheet sheet = excel['Nhat_Ky_Lam_Viec'];

      sheet.appendRow([
        TextCellValue('Mã Ca'),
        TextCellValue('ID Nhân Viên'),
        TextCellValue('Tên Nhân Viên'),
        TextCellValue('Nhiệm Vụ / Ca làm'),
        TextCellValue('Bắt Đầu'),
        TextCellValue('Kết Thúc'),
        TextCellValue('Trạng Thái')
      ]);

      for (final s in schedules) {
        sheet.appendRow([
          TextCellValue(s.id),
          TextCellValue(s.staffUid),
          TextCellValue(s.staffName),
          TextCellValue(s.task),
          TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(s.startTime)),
          TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(s.endTime)),
          TextCellValue(s.status)
        ]);
      }

      excel.delete('Sheet1');

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final dateStr = DateFormat('yyyyMMdd').format(controller.selectedDate);
        final fileName = 'Nhat_Ky_Lam_Viec_$dateStr.xlsx';
        await saveFile(fileBytes, fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xuất nhật ký làm việc Excel thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất nhật ký Excel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddScheduleDialog(),
    );
  }
}
