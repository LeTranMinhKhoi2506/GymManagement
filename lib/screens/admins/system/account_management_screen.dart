import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../../utils/validators.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String searchQuery = "";
  String filterRole = "Tất cả";
  String filterStatus = "Tất cả";

  final Map<String, String> _roleTranslations = {
    'admin': 'Quản trị viên (Admin)',
    'trainer': 'Huấn luyện viên (PT)',
    'receptionist': 'Lễ tân',
    'user': 'Hội viên',
  };

  final Map<String, String> _statusTranslations = {
    'active': 'Hoạt động',
    'inactive': 'Đã khóa',
  };

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'trainer':
        return Colors.orange;
      case 'receptionist':
        return Colors.blue;
      case 'user':
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    if (userController.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi tài khoản: ${userController.errorMessage!}")),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          userController.clearError();
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
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildFilterSection(),
                        const SizedBox(height: 24),
                        _buildUserList(),
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
            Text(
              "Quản lý tài khoản",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
            SizedBox(height: 4),
            Text(
              "Quản lý danh sách, vai trò và trạng thái hoạt động của người dùng hệ thống",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showUserDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text("Tạo tài khoản mới"),
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

  Widget _buildStatsRow() {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        return StreamBuilder<List<UserModel>>(
          stream: controller.usersStream,
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            final activeCount = list.where((u) => u.status == 'active').length;
            final lockedCount = list.where((u) => u.status == 'inactive').length;

            return Row(
              children: [
                _buildStatCard("Tổng cộng tài khoản", list.length.toString(), Icons.people, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard("Đang hoạt động", activeCount.toString(), Icons.check_circle, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard("Đã khóa / Tạm ngưng", lockedCount.toString(), Icons.block, Colors.red),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Tìm kiếm tài khoản theo tên, email, sđt...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              initialValue: filterRole,
              decoration: InputDecoration(
                labelText: "Vai trò",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ["Tất cả", ..._roleTranslations.keys].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == "Tất cả" ? "Tất cả vai trò" : _roleTranslations[value]!),
                );
              }).toList(),
              onChanged: (val) => setState(() => filterRole = val!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              initialValue: filterStatus,
              decoration: InputDecoration(
                labelText: "Trạng thái",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ["Tất cả", "active", "inactive"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == "Tất cả" 
                        ? "Tất cả trạng thái" 
                        : _statusTranslations[value]!,
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => filterStatus = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        return StreamBuilder<List<UserModel>>(
          stream: controller.usersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                ),
              );
            }
            var userList = snapshot.data ?? [];
            userList = userList.where((u) {
              final term = searchQuery.toLowerCase();
              final matchesSearch = u.fullName.toLowerCase().contains(term) ||
                  u.email.toLowerCase().contains(term) ||
                  (u.phoneNumber != null && u.phoneNumber!.contains(term));
              
              final matchesRole = filterRole == "Tất cả" || u.role == filterRole;
              final matchesStatus = filterStatus == "Tất cả" || u.status == filterStatus;

              return matchesSearch && matchesRole && matchesStatus;
            }).toList();

            if (userList.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Không tìm thấy tài khoản nào khớp với điều kiện lọc.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(label: Text("HỌ TÊN", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                  DataColumn(label: Text("EMAIL", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                  DataColumn(label: Text("SỐ ĐIỆN THOẠI", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                  DataColumn(label: Text("VAI TRÒ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                  DataColumn(label: Text("TRẠNG THÁI", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                  DataColumn(label: Text("THAO TÁC", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)))),
                ],
                rows: userList.map((user) => DataRow(cells: [
                  DataCell(
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                    ),
                  ),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.phoneNumber ?? "-")),
                  DataCell(
                    Chip(
                      label: Text(
                        _roleTranslations[user.role] ?? user.role,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: _getRoleColor(user.role),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (user.status == 'active' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusTranslations[user.status] ?? user.status,
                        style: TextStyle(
                          color: user.status == 'active' ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                          tooltip: "Chỉnh sửa thông tin",
                          onPressed: () => _showUserDialog(context, user: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.lock_reset, size: 18, color: Colors.orange),
                          tooltip: "Đặt lại mật khẩu",
                          onPressed: () => _showResetPasswordDialog(context, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          tooltip: "Xóa tài khoản",
                          onPressed: () => _confirmDelete(context, controller, user),
                        ),
                      ],
                    ),
                  ),
                ])).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDialog(BuildContext context, {UserModel? user}) {
    final formKey = GlobalKey<FormState>();
    final controller = Provider.of<UserController>(context, listen: false);

    String fullName = user?.fullName ?? "";
    String email = user?.email ?? "";
    String role = user?.role ?? "user";
    String status = user?.status ?? "active";
    String phoneNumber = user?.phoneNumber ?? "";
    String address = user?.address ?? "";
    String gender = user?.gender ?? "Nam";
    String position = user?.position ?? "";
    double salary = user?.salary ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? "Tạo tài khoản người dùng" : "Chỉnh sửa tài khoản"),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: fullName,
                    decoration: const InputDecoration(labelText: "Họ tên", prefixIcon: Icon(Icons.person)),
                    validator: Validators.validateFullName,
                    onSaved: (val) => fullName = val?.trim() ?? "",
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: "Email đăng nhập", prefixIcon: Icon(Icons.email)),
                    validator: Validators.validateEmail,
                    onSaved: (val) => email = val?.trim() ?? "",
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: phoneNumber,
                    decoration: const InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone)),
                    validator: Validators.validatePhoneNumber,
                    onSaved: (val) => phoneNumber = val?.trim() ?? "",
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: address,
                    decoration: const InputDecoration(labelText: "Địa chỉ liên hệ", prefixIcon: Icon(Icons.location_on)),
                    onSaved: (val) => address = val?.trim() ?? "",
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: gender,
                    decoration: const InputDecoration(labelText: "Giới tính", prefixIcon: Icon(Icons.wc)),
                    items: ["Nam", "Nữ", "Khác"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => gender = val!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: "Vai trò truy cập", prefixIcon: Icon(Icons.admin_panel_settings)),
                    items: _roleTranslations.entries.map((e) {
                      return DropdownMenuItem(value: e.key, child: Text(e.value));
                    }).toList(),
                    onChanged: (val) => role = val!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: "Trạng thái", prefixIcon: Icon(Icons.info_outline)),
                    items: [
                      const DropdownMenuItem(value: "active", child: Text("Đang hoạt động (Active)")),
                      const DropdownMenuItem(value: "inactive", child: Text("Đang khóa (Inactive)")),
                    ],
                    onChanged: (val) => status = val!,
                  ),
                  if (role == 'trainer' || role == 'receptionist') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: position.isEmpty ? (role == 'trainer' ? 'PT/Trainer' : 'Receptionist') : position,
                      decoration: const InputDecoration(labelText: "Vị trí công việc", prefixIcon: Icon(Icons.badge)),
                      onSaved: (val) => position = val?.trim() ?? "",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: salary == 0 ? "" : salary.toString(),
                      decoration: const InputDecoration(labelText: "Mức lương cơ bản (VNĐ)", prefixIcon: Icon(Icons.money)),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateSalary,
                      onSaved: (val) => salary = double.tryParse(val?.trim() ?? "0") ?? 0,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                final isDuplicate = await controller.checkEmailExists(email, excludeUid: user?.uid);
                if (isDuplicate) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Email này đã được sử dụng bởi một tài khoản khác!"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                  return;
                }

                try {
                  if (user == null) {
                    await controller.addUser(
                      fullName: fullName,
                      email: email,
                      role: role,
                      status: status,
                      phoneNumber: phoneNumber,
                      address: address,
                      gender: gender,
                      position: position.isNotEmpty ? position : null,
                      salary: salary > 0 ? salary : null,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Tạo tài khoản mới thành công!"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  } else {
                    await controller.updateUser(user.copyWith(
                      fullName: fullName,
                      email: email,
                      role: role,
                      status: status,
                      phoneNumber: phoneNumber,
                      address: address,
                      gender: gender,
                      position: position.isNotEmpty ? position : null,
                      salary: salary > 0 ? salary : null,
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Cập nhật thông tin tài khoản thành công!"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Có lỗi xảy ra: $e"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            child: const Text("Lưu thay đổi"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserController controller, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa tài khoản"),
        content: Text("Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản của ${user.fullName} (${user.email}) khỏi hệ thống?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteUser(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã xóa tài khoản ${user.fullName}"),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi khi xóa: $e"),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            }, 
            child: const Text("Xóa tài khoản", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFFFF6B35)),
            SizedBox(width: 10),
            Text("Đặt lại mật khẩu"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hệ thống bảo mật Firebase sẽ gửi một email hướng dẫn đặt lại mật khẩu đến hộp thư của người dùng này:",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A192F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Người dùng sẽ nhận được đường dẫn để tự thiết lập mật khẩu mới.",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = Provider.of<AuthController>(context, listen: false);
              final result = await authController.resetPassword(user.email);
              if (context.mounted) {
                if (result == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã gửi email đặt lại mật khẩu thành công tới ${user.email}!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi khi gửi email: $result"),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Gửi email đặt lại"),
          ),
        ],
      ),
    );
  }
}
