import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../controllers/membership_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../data/models/membership_plan_model.dart';
import '../../common/widgets/admin_dashboard_widgets/sidebar_widget.dart';
import '../../common/widgets/admin_dashboard_widgets/header_widget.dart';
import '../../common/widgets/custom_text_field.dart';

class MembershipManagementScreen extends StatefulWidget {
  const MembershipManagementScreen({super.key});

  @override
  State<MembershipManagementScreen> createState() => _MembershipManagementScreenState();
}

class _MembershipManagementScreenState extends State<MembershipManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo filter theo tab mặc định (ĐANG HOẠT ĐỘNG)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipController>().setStatusFilter(true);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final controller = context.read<MembershipController>();
        if (_tabController.index == 0) {
          controller.setStatusFilter(true); // Active
        } else if (_tabController.index == 1) {
          controller.setStatusFilter(null); // All
        } else {
          controller.setStatusFilter(false); // Inactive
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xuất file CSV chuyên nghiệp
  Future<void> _exportToCSV(List<MembershipPlan> plans) async {
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không có dữ liệu để xuất")),
      );
      return;
    }

    List<List<dynamic>> rows = [];
    // Tiêu đề cột
    rows.add(["ID", "Tên gói", "Mô tả", "Giá (VNĐ)", "Thời hạn (Tháng)", "Có PT", "Trạng thái"]);

    for (var plan in plans) {
      rows.add([
        plan.id,
        plan.name,
        plan.description,
        plan.price,
        plan.durationMonths,
        plan.hasPT ? "Có" : "Không",
        plan.isActive ? "Hoạt động" : "Lưu trữ"
      ]);
    }

    String csvContent = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/danh_sach_goi_tap_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvContent);

    await Share.shareXFiles([XFile(path)], text: 'Dữ liệu gói tập Gym');
  }

  void _showFilterDialog(BuildContext context) {
    final controller = context.read<MembershipController>();
    final minController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Bộ lọc nâng cao & Sắp xếp"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Khoảng giá (VNĐ)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: minController, label: "Từ", keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: maxController, label: "Đến", keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Sắp xếp theo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _sortChip("Tên", MembershipSortOption.name, controller),
                _sortChip("Giá", MembershipSortOption.price, controller),
                _sortChip("Thời hạn", MembershipSortOption.duration, controller),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              _searchController.clear();
              Navigator.pop(context);
            },
            child: const Text("Xóa bộ lọc", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              double? min = double.tryParse(minController.text);
              double? max = double.tryParse(maxController.text);
              controller.setPriceFilter(min, max);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            child: const Text("Áp dụng"),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, MembershipSortOption option, MembershipController controller) {
    return ActionChip(
      label: Text(label),
      onPressed: () => controller.setSortOption(option),
      backgroundColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MembershipController>(context);
    final customerController = context.watch<CustomerController>();
    final adminController = context.watch<AdminController>();

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
                        _buildBreadcrumbs(),
                        const SizedBox(height: 12),
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildTabsAndFilters(controller),
                        const SizedBox(height: 24),
                        _buildMembershipTable(controller),
                        const SizedBox(height: 32),
                        _buildStatsSummary(customerController, adminController),
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

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text("Admin", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text(" Quản lý gói tập", style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gói thành viên", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            SizedBox(height: 4),
            Text("Quản lý danh sách và cấu hình các gói dịch vụ tại phòng tập", style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showPlanDialog(context),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text("Tạo gói tập mới", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabsAndFilters(MembershipController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFFF6B35),
          labelColor: const Color(0xFF0A192F),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "ĐANG HOẠT ĐỘNG"),
            Tab(text: "TẤT CẢ"),
            Tab(text: "LƯU TRỮ"),
          ],
        ),
        Row(
          children: [
            if (controller.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () {
                    controller.clearFilters();
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text("Xóa lọc"),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => controller.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: "Tìm theo tên gói tập...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildActionIcon(Icons.filter_list, () => _showFilterDialog(context), "Lọc & Sắp xếp"),
            const SizedBox(width: 12),
            _buildActionIcon(Icons.download, () => _exportToCSV(controller.plans), "Xuất CSV"),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(icon, size: 20, color: Colors.blueGrey[800]),
        ),
      ),
    );
  }

  Widget _buildMembershipTable(MembershipController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          if (controller.isLoading)
            const Padding(padding: EdgeInsets.all(60.0), child: Center(child: CircularProgressIndicator()))
          else if (controller.plans.isEmpty)
            const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(child: Text("Không có gói tập nào phù hợp với bộ lọc.", style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.plans.length,
              itemBuilder: (context, index) => _buildTableRow(controller.plans[index]),
            ),
          _buildTableFooter(controller.plans.length),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _headerText("TÊN GÓI", 3),
          _headerText("GIÁ HÀNG THÁNG", 2),
          _headerText("HỘI VIÊN", 1),
          _headerText("SỨC KHỎE GIỮ CHÂN", 2),
          _headerText("TRẠNG THÁI", 1),
          _headerText("THAO TÁC", 1, alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  Widget _headerText(String text, int flex, {Alignment alignment = Alignment.centerLeft}) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(color: Colors.blueGrey[300], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildTableRow(MembershipPlan plan) {
    final customerController = context.watch<CustomerController>();
    final allMembers = customerController.allMembers;
    final planMembers = allMembers
        .where((m) => m.membershipType.toLowerCase().trim() == plan.name.toLowerCase().trim())
        .toList();
    final subscriberCount = planMembers.length;
    final activeCount = planMembers.where((m) => m.status == 'Active').length;
    final retentionHealth = subscriberCount > 0 ? (activeCount / subscriberCount) : 1.0;

    final f = NumberFormat.decimalPattern('vi_VN');
    final formattedRetention = "${(retentionHealth * 100).toStringAsFixed(0)}%";
    Color retentionColor = retentionHealth < 0.5 ? Colors.redAccent : (retentionHealth < 0.8 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[50]!))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFF6B35).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bolt, color: Color(0xFFFF6B35), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A192F))),
                      Text(plan.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text("${f.format(plan.price)} ₫", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Expanded(flex: 1, child: Text(subscriberCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: retentionHealth, color: retentionColor, backgroundColor: const Color(0xFFEEEEEE), minHeight: 4)),
                const SizedBox(width: 8),
                Text(formattedRetention, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: retentionColor)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: plan.isActive ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(4)),
              child: Text(plan.isActive ? "HOẠT ĐỘNG" : "LƯU TRỮ", style: TextStyle(color: plan.isActive ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: () => _showPlanDialog(context, plan: plan)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => _showDeleteConfirm(context, plan)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableFooter(int count) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("TỔNG CỘNG: $count GÓI TẬP", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(CustomerController customerController, AdminController adminController) {
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final activeMembers = customerController.allMembers.where((m) => m.status == 'Active').length;
    final monthlyRevenue = adminController.monthlyRevenue;
    final thisMonthRevenue = monthlyRevenue.isNotEmpty ? monthlyRevenue.last : 0.0;

    return Row(
      children: [
        _buildStatCard("DOANH THU THÁNG", f.format(thisMonthRevenue), "Tăng trưởng ổn định", Colors.green),
        const SizedBox(width: 24),
        _buildStatCard("HỘI VIÊN HOẠT ĐỘNG", activeMembers.toString(), "Tham gia thường xuyên", Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String description, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                const SizedBox(width: 8),
                Text(description, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanDialog(BuildContext context, {MembershipPlan? plan}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan?.name);
    final descController = TextEditingController(text: plan?.description);
    final priceController = TextEditingController(text: plan != null ? plan.price.toStringAsFixed(0) : '');
    final durationController = TextEditingController(text: plan != null ? plan.durationMonths.toString() : '');
    bool hasPT = plan?.hasPT ?? false;
    bool isActive = plan?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(plan == null ? 'Thêm gói tập mới' : 'Sửa gói tập'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: nameController, label: 'Tên gói tập', validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null),
                    const SizedBox(height: 16),
                    CustomTextField(controller: descController, label: 'Mô tả'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: priceController, label: 'Giá (VNĐ)', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    CustomTextField(controller: durationController, label: 'Thời hạn (Tháng)', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                        title: const Text('Có huấn luyện viên (PT)'),
                        value: hasPT,
                        activeColor: const Color(0xFFFF6B35),
                        onChanged: (val) => setState(() => hasPT = val ?? false)
                    ),
                    SwitchListTile(
                        title: const Text('Kích hoạt gói tập'),
                        value: isActive,
                        activeColor: const Color(0xFFFF6B35),
                        onChanged: (val) => setState(() => isActive = val)
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newPlan = MembershipPlan(
                    id: plan?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0,
                    durationMonths: int.tryParse(durationController.text) ?? 1,
                    hasPT: hasPT,
                    isActive: isActive,
                  );
                  if (plan == null) await context.read<MembershipController>().addPlan(newPlan);
                  else await context.read<MembershipController>().updatePlan(newPlan);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, MembershipPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa gói "${plan.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<MembershipController>().deletePlan(plan.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}