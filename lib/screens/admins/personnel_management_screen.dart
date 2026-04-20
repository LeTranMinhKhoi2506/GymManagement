import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/staff_controller.dart';
import '../../controllers/schedule_controller.dart';
import '../../data/models/user_model.dart';
import '../../data/models/schedule_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../common/widgets/admin_personnel_widgets/active_shifts_widget.dart';
import '../../utils/validators.dart';

class PersonnelManagementScreen extends StatefulWidget {
  const PersonnelManagementScreen({super.key});

  @override
  State<PersonnelManagementScreen> createState() => _PersonnelManagementScreenState();
}

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen> {
  String searchQuery = "";
  String filterPosition = "Tất cả";
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nội dung chính (Trái)
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 32),
                              _buildStatsRow(),
                              const SizedBox(height: 32),
                              _buildFilterSection(),
                              const SizedBox(height: 24),
                              _buildStaffList(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Nội dung bên cạnh (Phải) - Widget Ca làm việc
                        Column(
                          children: [
                            Consumer<ScheduleController>(
                              builder: (context, controller, child) {
                                return StreamBuilder<List<ScheduleModel>>(
                                  stream: controller.todaySchedulesStream,
                                  builder: (context, snapshot) {
                                    final schedules = snapshot.data ?? [];
                                    return ActiveShiftsWidget(
                                      schedules: schedules,
                                    );
                                  },
                                );
                              },
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
              "Quản lý nhân sự",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
            Text("Quản lý thông tin và hiệu suất của đội ngũ nhân viên",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showStaffDialog(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text("Thêm nhân viên mới"),
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
    return Consumer<StaffController>(
      builder: (context, controller, child) {
        return StreamBuilder<List<UserModel>>(
          stream: controller.staffStream,
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            final activeCount = list.where((s) => s.status == 'active').length;
            final trainerCount = list.where((s) => s.position == 'PT/Trainer').length;

            return Row(
              children: [
                _buildStatCard("Tổng cộng", list.length.toString(), Icons.people, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard("Đang làm việc", activeCount.toString(), Icons.check_circle, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard("PT/Trainer", trainerCount.toString(), Icons.fitness_center, Colors.orange),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Tìm kiếm nhân viên...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: filterPosition,
            underline: const SizedBox(),
            items: ["Tất cả", "Quản lý", "PT/Trainer", "Lễ tân"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (val) => setState(() => filterPosition = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Consumer<StaffController>(
      builder: (context, controller, child) {
        return StreamBuilder<List<UserModel>>(
          stream: controller.staffStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            var staffList = snapshot.data ?? [];
            staffList = staffList.where((s) {
              final matchesSearch = s.fullName.toLowerCase().contains(searchQuery.toLowerCase());
              final matchesFilter = filterPosition == "Tất cả" || s.position == filterPosition;
              return matchesSearch && matchesFilter;
            }).toList();

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("NHÂN VIÊN", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("CHỨC VỤ", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("TRẠNG THÁI", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("THAO TÁC", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: staffList.map((staff) => DataRow(cells: [
                  DataCell(Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(staff.position ?? "-")),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: (staff.status == 'active' ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(staff.status == 'active' ? "Đang làm" : "Nghỉ", style: TextStyle(color: staff.status == 'active' ? Colors.green : Colors.red, fontSize: 11)),
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showStaffDialog(context, staff: staff)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _confirmDelete(context, controller, staff)),
                    ],
                  )),
                ])).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showStaffDialog(BuildContext context, {UserModel? staff}) {
    final formKey = GlobalKey<FormState>();
    final controller = Provider.of<StaffController>(context, listen: false);

    String fullName = staff?.fullName ?? "";
    String email = staff?.email ?? "";
    String position = staff?.position ?? "PT/Trainer";
    String phoneNumber = staff?.phoneNumber ?? "";
    double salary = staff?.salary ?? 0;
    String address = staff?.address ?? "";
    String gender = staff?.gender ?? "Nam";
    String status = staff?.status ?? "active";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff == null ? "Thêm nhân viên nhanh" : "Cập nhật hồ sơ chi tiết"),
        content: SizedBox(
          width: 500,
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
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                    validator: Validators.validateEmail,
                    onSaved: (val) => email = val?.trim() ?? "",
                  ),
                  if (staff != null) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: phoneNumber,
                      decoration: const InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone)),
                      validator: Validators.validatePhoneNumber,
                      onSaved: (val) => phoneNumber = val?.trim() ?? "",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: salary == 0 ? "" : salary.toString(),
                      decoration: const InputDecoration(labelText: "Mức lương (VNĐ)", prefixIcon: Icon(Icons.money)),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateSalary,
                      onSaved: (val) => salary = double.tryParse(val?.trim() ?? "0") ?? 0,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: address,
                      decoration: const InputDecoration(labelText: "Địa chỉ", prefixIcon: Icon(Icons.location_on)),
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
                      initialValue: status,
                      decoration: const InputDecoration(labelText: "Trạng thái", prefixIcon: Icon(Icons.info_outline)),
                      items: [
                        const DropdownMenuItem(value: "active", child: Text("Đang làm việc")),
                        const DropdownMenuItem(value: "inactive", child: Text("Nghỉ việc")),
                      ],
                      onChanged: (val) => status = val!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: position,
                    decoration: const InputDecoration(labelText: "Chức vụ", prefixIcon: Icon(Icons.badge_outlined)),
                    items: ["Quản lý", "PT/Trainer", "Lễ tân"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => position = val!,
                  ),
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
                
                // Kiểm tra email trùng
                final isDuplicate = await controller.checkEmailExists(email, excludeUid: staff?.uid);
                if (isDuplicate) {
                  if (context.mounted) {
                    _showSnackBar(context, "Email này đã tồn tại trong hệ thống!", Colors.red);
                  }
                  return;
                }

                try {
                  if (staff == null) {
                    await controller.addStaffExtended(
                      fullName: fullName,
                      email: email,
                      phoneNumber: "",
                      position: position,
                      salary: 0,
                      address: "",
                      status: "active",
                    );
                    _showSnackBar(context, "Thêm nhân viên thành công", Colors.green);
                  } else {
                    await controller.updateStaff(staff.copyWith(
                      fullName: fullName,
                      email: email, // Bây giờ có thể sửa email
                      position: position,
                      phoneNumber: phoneNumber,
                      salary: salary,
                      address: address,
                      gender: gender,
                      status: status,
                    ));
                    _showSnackBar(context, "Cập nhật thành công", Colors.green);
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  _showSnackBar(context, "Có lỗi xảy ra: $e", Colors.red);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StaffController controller, UserModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa nhân viên ${staff.fullName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteStaff(staff.uid);
                _showSnackBar(context, "Đã xóa nhân viên", Colors.orange);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                _showSnackBar(context, "Lỗi khi xóa: $e", Colors.red);
              }
            }, 
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
