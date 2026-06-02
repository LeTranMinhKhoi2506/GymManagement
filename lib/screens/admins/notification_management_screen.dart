import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/notification_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context);
    final authController = Provider.of<AuthController>(context);

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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildNotificationList(notificationController)),
                            const SizedBox(width: 32),
                            Expanded(flex: 1, child: _buildComposeSection(notificationController, authController)),
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
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quản lý thông báo",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
        ),
        Text("Gửi thông báo đẩy và quản lý lịch sử thông báo hệ thống",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildNotificationList(NotificationController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lịch sử thông báo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (controller.notifications.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text("Chưa có thông báo nào được gửi."),
            ))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.notifications.length > 10 ? 10 : controller.notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final notif = controller.notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTypeColor(notif.type).withValues(alpha: 0.1),
                    child: Icon(_getTypeIcon(notif.type), color: _getTypeColor(notif.type), size: 20),
                  ),
                  title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.message),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => controller.deleteNotification(notif.id),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComposeSection(NotificationController controller, AuthController auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Soạn thông báo mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: "Loại thông báo", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'general', child: Text("Thông báo chung")),
                DropdownMenuItem(value: 'promotion', child: Text("Khuyến mãi")),
                DropdownMenuItem(value: 'alert', child: Text("Cảnh báo/Bảo trì")),
              ],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Vui lòng nhập tiêu đề" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Nội dung", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Vui lòng nhập nội dung" : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    await controller.sendNotification(
                      title: _titleController.text,
                      message: _messageController.text,
                      type: _selectedType,
                      sentBy: auth.currentUser?.fullName,
                    );
                    _titleController.clear();
                    _messageController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã gửi thông báo thành công!")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("GỬI THÔNG BÁO", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'promotion': return Colors.orange;
      case 'alert': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'promotion': return Icons.campaign;
      case 'alert': return Icons.warning_amber;
      default: return Icons.notifications_none;
    }
  }
}
