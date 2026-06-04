import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/role_controller.dart';
import '../../../data/models/role_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  // Danh sách các quyền hạn hệ thống dựa trên yêu cầu trong ảnh
  final Map<String, List<String>> _permissionGroups = {
    'Người dùng': ['view_users', 'edit_users', 'ban_users', 'delete_users'],
    'Nội dung': ['create_content', 'edit_content', 'publish_content', 'delete_content'],
    'Hệ thống': ['manage_admins', 'assign_roles', 'view_sessions', 'view_reports'],
    'Truyền thông': ['send_notifications', 'reply_feedback', 'manage_media'],
  };

  final Map<String, String> _permissionTranslations = {
    'view_users': 'Xem người dùng',
    'edit_users': 'Sửa người dùng',
    'ban_users': 'Khóa người dùng',
    'delete_users': 'Xóa người dùng',
    'create_content': 'Tạo nội dung',
    'edit_content': 'Sửa nội dung',
    'publish_content': 'Xuất bản nội dung',
    'delete_content': 'Xóa nội dung',
    'manage_admins': 'Quản lý Admin',
    'assign_roles': 'Phân quyền',
    'view_sessions': 'Xem phiên tập',
    'view_reports': 'Xem báo cáo',
    'send_notifications': 'Gửi thông báo',
    'reply_feedback': 'Trả lời phản hồi',
    'manage_media': 'Quản lý Media',
  };

  @override
  Widget build(BuildContext context) {
    final roleController = Provider.of<RoleController>(context);

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
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildRoleGrid(roleController),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vai trò & Quyền hạn", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            Text("Quản lý các cấp bậc truy cập và phân quyền nhân sự", 
              style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showRoleDialog(context),
          icon: const Icon(Icons.add_moderator),
          label: const Text("Tạo vai trò mới"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleGrid(RoleController controller) {
    if (controller.roles.isEmpty) {
      return const Center(child: Text("Chưa có vai trò nào được định nghĩa."));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: controller.roles.length,
      itemBuilder: (context, index) {
        final role = controller.roles[index];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(role.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildActionButtons(role, controller),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text("QUYỀN HẠN:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: role.permissions.map((p) => Chip(
                      label: Text(_permissionTranslations[p] ?? p, style: const TextStyle(fontSize: 10)),
                      backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(RoleModel role, RoleController controller) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
          onPressed: () => _showRoleDialog(context, role: role),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          onPressed: () => controller.deleteRole(role.id),
        ),
      ],
    );
  }

  void _showRoleDialog(BuildContext context, {RoleModel? role}) {
    final nameController = TextEditingController(text: role?.name);
    List<String> selectedPermissions = List.from(role?.permissions ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(role == null ? "Tạo vai trò mới" : "Chỉnh sửa vai trò"),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Tên vai trò", hintText: "VD: Kế toán trưởng"),
                  ),
                  const SizedBox(height: 24),
                  ..._permissionGroups.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                      ),
                      Wrap(
                        spacing: 8,
                        children: entry.value.map((p) {
                          final isSelected = selectedPermissions.contains(p);
                          return FilterChip(
                            label: Text(_permissionTranslations[p] ?? p),
                            selected: isSelected,
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedPermissions.add(p);
                                } else {
                                  selectedPermissions.remove(p);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final controller = context.read<RoleController>();
                  if (role == null) {
                    controller.addRole(nameController.text, selectedPermissions);
                  } else {
                    controller.updateRole(RoleModel(id: role.id, name: nameController.text, permissions: selectedPermissions));
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: const Text("Lưu thay đổi"),
            ),
          ],
        ),
      ),
    );
  }
}
