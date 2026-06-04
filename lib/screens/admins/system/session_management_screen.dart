import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/session_controller.dart';
import '../../../data/models/session_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final sessionController = Provider.of<SessionController>(context);

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
                        _buildSessionTable(sessionController),
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
        Text(
          "Quản lý phiên đăng nhập",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
        ),
        Text("Theo dõi các thiết bị và hoạt động truy cập vào hệ thống quản trị",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSessionTable(SessionController controller) {
    if (controller.sessions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(100.0),
        child: Text("Không có lịch sử đăng nhập."),
      ));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("NGƯỜI DÙNG")),
          DataColumn(label: Text("THIẾT BỊ")),
          DataColumn(label: Text("ĐỊA CHỈ IP")),
          DataColumn(label: Text("THỜI GIAN")),
          DataColumn(label: Text("THAO TÁC")),
        ],
        rows: controller.sessions.map((session) => DataRow(cells: [
          DataCell(Text(session.userName, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Row(
            children: [
              Icon(session.device.contains('Windows') ? Icons.laptop : Icons.smartphone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(session.device),
            ],
          )),
          DataCell(Text(session.ipAddress)),
          DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(session.loginAt))),
          DataCell(IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            onPressed: () => _showRevokeDialog(session, controller),
            tooltip: "Kết thúc phiên",
          )),
        ])).toList(),
      ),
    );
  }

  void _showRevokeDialog(SessionModel session, SessionController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kết thúc phiên?"),
        content: Text("Bạn có muốn đăng xuất tài khoản ${session.userName} khỏi thiết bị ${session.device} không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              controller.deleteSession(session.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}
