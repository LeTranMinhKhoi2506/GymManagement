import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/report_controller.dart';
import '../../../data/models/report_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({super.key});

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final reportController = Provider.of<ReportController>(context);

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
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildReportList(reportController),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Báo cáo vi phạm", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
        Text("Xử lý các báo cáo từ cộng đồng về người dùng hoặc nội dung", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildReportList(ReportController controller) {
    if (controller.reports.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(100.0),
        child: Text("Hiện không có báo cáo nào cần xử lý."),
      ));
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("NGƯỜI BÁO CÁO")),
          DataColumn(label: Text("LOẠI")),
          DataColumn(label: Text("LÝ DO")),
          DataColumn(label: Text("TRẠNG THÁI")),
          DataColumn(label: Text("THAO TÁC")),
        ],
        rows: controller.reports.map((report) => DataRow(cells: [
          DataCell(Text(report.reporterName)),
          DataCell(Chip(label: Text(report.type.toUpperCase(), style: const TextStyle(fontSize: 10)))),
          DataCell(Text(report.reason, maxLines: 1, overflow: TextOverflow.ellipsis)),
          DataCell(_buildStatusBadge(report.status)),
          DataCell(Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_red_eye_outlined, size: 18), onPressed: () => _showDetailDialog(report, controller)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => controller.deleteReport(report.id)),
            ],
          )),
        ])).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'pending' ? Colors.orange : (status == 'resolved' ? Colors.green : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showDetailDialog(ReportModel report, ReportController controller) {
    final noteController = TextEditingController(text: report.adminNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chi tiết báo cáo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Người báo cáo: ${report.reporterName}"),
            Text("Đối tượng bị báo cáo (ID): ${report.reportedItemId}"),
            const SizedBox(height: 12),
            const Text("Lý do vi phạm:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(report.reason),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Ghi chú của Admin", border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          ElevatedButton(
            onPressed: () async {
              await controller.updateReportStatus(report.id, 'resolved', adminNote: noteController.text);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Đánh dấu Đã giải quyết"),
          ),
        ],
      ),
    );
  }
}
