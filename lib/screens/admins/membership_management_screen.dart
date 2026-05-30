import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MembershipController>(context);
    final customerController = context.watch<CustomerController>();
    final adminController = context.watch<AdminController>();

    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Lỗi gói tập: ${controller.errorMessage!}")),
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
                        _buildBreadcrumbs(),
                        const SizedBox(height: 12),
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildTabsAndFilters(),
                        const SizedBox(height: 24),
                        _buildMembershipTable(),
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
            SizedBox(height: 4),
            Text("Gói thành viên", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
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

  Widget _buildTabsAndFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFFF6B35),
          labelColor: const Color(0xFF0A192F),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "ĐANG HOẠT ĐỘNG"),
            Tab(text: "LỊCH SỬ"),
            Tab(text: "LƯU TRỮ"),
          ],
        ),
        Row(
          children: [
            _buildOutlineButton(Icons.filter_list, "Bộ lọc nâng cao"),
            const SizedBox(width: 12),
            _buildOutlineButton(Icons.download, "Xuất CSV"),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlineButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueGrey[800],
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMembershipTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Consumer<MembershipController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          final filteredPlans = controller.plans.where((plan) {
            if (_tabController.index == 0) {
              return plan.isActive;
            } else if (_tabController.index == 2) {
              return !plan.isActive;
            }
            return true;
          }).toList();

          return Column(
            children: [
              _buildTableHeader(),
              const Divider(height: 1),
              if (filteredPlans.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: Text("Không có gói tập nào.")),
                )
              else
                Column(
                  children: filteredPlans.map((plan) => _buildTableRow(plan)).toList(),
                ),
              _buildTableFooter(filteredPlans.length, controller.plans.length),
            ],
          );
        },
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
    final formattedSubscribers = f.format(subscriberCount);
    final formattedRetention = "${(retentionHealth * 100).toStringAsFixed(1)}%";

    Color retentionColor = Colors.green;
    if (retentionHealth < 0.5) {
      retentionColor = Colors.redAccent;
    } else if (retentionHealth < 0.8) {
      retentionColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[50]!)),
      ),
      child: Row(
        children: [
          // Plan Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Color(0xFFFF6B35), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A192F))),
                      const SizedBox(height: 2),
                      Text(plan.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Text(
              "${f.format(plan.price)} VNĐ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          // Subscribers
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedSubscribers, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(4, (i) {
                    final colorLevel = subscriberCount > 100 ? 4 : (subscriberCount > 50 ? 3 : (subscriberCount > 10 ? 2 : (subscriberCount > 0 ? 1 : 0)));
                    return Container(
                      width: 8, height: 4, 
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(color: i < colorLevel ? Colors.orange : Colors.grey[200], borderRadius: BorderRadius.circular(2)),
                    );
                  }),
                )
              ],
            ),
          ),
          // Retention Health
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: retentionHealth, 
                      color: retentionColor, 
                      backgroundColor: const Color(0xFFEEEEEE), 
                      minHeight: 4
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(formattedRetention, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: retentionColor)),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: plan.isActive ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                plan.isActive ? "HOẠT ĐỘNG" : "CHỜ",
                style: TextStyle(color: plan.isActive ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  onPressed: () => _showPlanDialog(context, plan: plan),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirm(context, plan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableFooter(int filteredCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "HIỂN THỊ $filteredCount TRONG $totalCount GÓI TẬP",
            style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsSummary(
    CustomerController customerController,
    AdminController adminController,
  ) {
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final fNum = NumberFormat.decimalPattern('vi_VN');

    final allMembers = customerController.allMembers;
    final activeMembers = allMembers.where((m) => m.status == 'Active').length;
    final inactiveMembers = allMembers.length - activeMembers;

    // Tổng doanh thu tháng hiện tại từ AdminController
    final monthlyRevenue = adminController.monthlyRevenue;
    final currentMonth = DateTime.now().month - 1;
    final thisMonthRevenue = currentMonth >= 0 && currentMonth < monthlyRevenue.length
        ? monthlyRevenue[currentMonth]
        : 0.0;
    final lastMonthRevenue = currentMonth > 0 && currentMonth - 1 < monthlyRevenue.length
        ? monthlyRevenue[currentMonth - 1]
        : 0.0;
    double revenueDiff = 0;
    String revenueTrend = "Ổn định";
    Color revenueTrendColor = Colors.grey;
    if (lastMonthRevenue > 0) {
      revenueDiff = ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
      revenueTrend = "${revenueDiff >= 0 ? '+' : ''}${revenueDiff.toStringAsFixed(0)}%";
      revenueTrendColor = revenueDiff >= 0 ? Colors.green : Colors.redAccent;
    }

    // LTV trung bình của hội viên
    final avgLtv = allMembers.isNotEmpty
        ? allMembers.fold(0.0, (sum, m) => sum + m.ltv) / allMembers.length
        : 0.0;

    // Tỷ lệ rời bỏ
    final churnRate = allMembers.isNotEmpty ? (inactiveMembers / allMembers.length) * 100 : 0.0;
    Color churnColor = churnRate > 10 ? Colors.redAccent : (churnRate > 5 ? Colors.orange : Colors.blue);
    String churnTrend = churnRate > 10 ? "Cần chú ý" : (churnRate > 5 ? "Theo dõi" : "Ổn định");

    return Row(
      children: [
        _buildStatCard(
          "TỔNG DOANH THU THÁNG",
          f.format(thisMonthRevenue),
          revenueTrend,
          revenueTrendColor,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "HỘI VIÊN ĐANG HOẠT ĐỘNG",
          fNum.format(activeMembers),
          "Tổng ${fNum.format(allMembers.length)} hội viên",
          Colors.grey,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "GIÁ TRỊ TB TRỌN ĐỜI",
          f.format(avgLtv),
          avgLtv > 0 ? "Từ ${fNum.format(allMembers.length)} hội viên" : "Chưa có dữ liệu",
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "TỶ LỆ RỜI BỎ",
          "${churnRate.toStringAsFixed(1)}%",
          churnTrend,
          churnColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String trend, Color trendColor) {
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
                Text(trend, style: TextStyle(color: trendColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
                    CustomTextField(
                      controller: nameController,
                      label: 'Tên gói tập',
                      hintText: 'VD: Gói VIP 6 tháng',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập tên gói tập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: descController,
                      label: 'Mô tả',
                      hintText: 'Quyền lợi gói tập...',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả gói tập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: priceController,
                      label: 'Giá (VNĐ)',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập giá';
                        }
                        final price = double.tryParse(val);
                        if (price == null || price <= 0) {
                          return 'Giá phải là số dương hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: durationController,
                      label: 'Thời hạn (Tháng)',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập thời hạn';
                        }
                        final duration = int.tryParse(val);
                        if (duration == null || duration <= 0) {
                          return 'Thời hạn phải là số nguyên dương hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Có huấn luyện viên (PT)'),
                      value: hasPT,
                      onChanged: (val) => setState(() => hasPT = val ?? false),
                      contentPadding: EdgeInsets.zero,
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFFFF6B35);
                        }
                        return Colors.grey.shade300;
                      }),
                    ),
                    SwitchListTile(
                      title: const Text('Kích hoạt gói tập'),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: const Color(0xFFFF6B35),
                      activeTrackColor: const Color(0xFFFF6B35).withValues(alpha: 0.4),
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
                  final controller = context.read<MembershipController>();
                  final newPlan = MembershipPlan(
                    id: plan?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0,
                    durationMonths: int.tryParse(durationController.text) ?? 1,
                    hasPT: hasPT,
                    isActive: isActive,
                  );
                  try {
                    if (plan == null) {
                      await controller.addPlan(newPlan);
                    } else {
                      await controller.updatePlan(newPlan);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (_) {
                    // Error is already handled by controller errorMessage stream,
                    // but we catch to prevent popping on failure.
                  }
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
        content: Text('Bạn có chắc chắn muốn xóa gói tập "${plan.name}" không?'),
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
