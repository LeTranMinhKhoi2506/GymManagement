import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/route/routes.dart';
import '../../../controllers/customer_controller.dart';
import '../../../controllers/membership_controller.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/membership_plan_model.dart';

class AdminSearchDialog extends StatefulWidget {
  const AdminSearchDialog({super.key});

  @override
  State<AdminSearchDialog> createState() => _AdminSearchDialogState();
}

class _AdminSearchDialogState extends State<AdminSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Danh sách các trang/chức năng hệ thống tĩnh
  final List<Map<String, dynamic>> _systemPages = [
    {
      'title': 'Bảng điều khiển',
      'description': 'Tổng quan hệ thống, doanh thu, check-in',
      'route': Routes.adminDashboard,
      'icon': Icons.dashboard_outlined,
      'category': 'Hệ thống'
    },
    {
      'title': 'Quản lý Tài khoản',
      'description': 'Quản lý tài khoản đăng nhập hệ thống',
      'route': Routes.accountManagement,
      'icon': Icons.manage_accounts_outlined,
      'category': 'Hệ thống'
    },
    {
      'title': 'Quản lý Cửa hàng',
      'description': 'Sản phẩm, dịch vụ và kho hàng',
      'route': Routes.storeManagement,
      'icon': Icons.store_outlined,
      'category': 'Vận hành'
    },
    {
      'title': 'Quản lý Hội viên',
      'description': 'Danh sách khách hàng và nhật ký tập luyện',
      'route': Routes.customerManagement,
      'icon': Icons.group_outlined,
      'category': 'Hội viên'
    },
    {
      'title': 'Quản lý Gói tập',
      'description': 'Cấu hình các gói dịch vụ tập luyện',
      'route': Routes.membershipManagement,
      'icon': Icons.card_membership_outlined,
      'category': 'Hội viên'
    },
    {
      'title': 'Quản lý Nhân sự',
      'description': 'Huấn luyện viên, nhân viên tiếp tân',
      'route': Routes.personnelManagement,
      'icon': Icons.badge_outlined,
      'category': 'Vận hành'
    },
    {
      'title': 'Lịch làm việc',
      'description': 'Lịch làm việc và lịch dạy của PT',
      'route': Routes.scheduleManagement,
      'icon': Icons.calendar_month_outlined,
      'category': 'Vận hành'
    },
    {
      'title': 'Quản lý Thiết bị',
      'description': 'Theo dõi và bảo trì thiết bị phòng gym',
      'route': Routes.equipmentManagement,
      'icon': Icons.build_outlined,
      'category': 'Vận hành'
    },
    {
      'title': 'Báo cáo tài chính',
      'description': 'Phân tích doanh thu và chi phí',
      'route': Routes.financialManagement,
      'icon': Icons.analytics_outlined,
      'category': 'Tài chính'
    },
    {
      'title': 'Thanh toán hội viên',
      'description': 'Hóa đơn và lịch sử giao dịch',
      'route': Routes.paymentManagement,
      'icon': Icons.payment_outlined,
      'category': 'Tài chính'
    },
    {
      'title': 'Lương nhân sự',
      'description': 'Tính lương và chi trả cho nhân viên',
      'route': Routes.payrollManagement,
      'icon': Icons.paid_outlined,
      'category': 'Tài chính'
    },
    {
      'title': 'Bài viết & Tin tức',
      'description': 'Quản lý tin tức, bài viết khuyến mãi',
      'route': Routes.contentManagement,
      'icon': Icons.article_outlined,
      'category': 'Nội dung'
    },
    {
      'title': 'Thông báo đẩy',
      'description': 'Soạn và gửi thông báo cho khách hàng',
      'route': Routes.notificationManagement,
      'icon': Icons.notifications_active_outlined,
      'category': 'Truyền thông'
    },
    {
      'title': 'Phản hồi hội viên',
      'description': 'Ý kiến đóng góp và khiếu nại',
      'route': Routes.feedbackManagement,
      'icon': Icons.feedback_outlined,
      'category': 'Truyền thông'
    },
    {
      'title': 'Phân quyền (Roles)',
      'description': 'Thiết lập vai trò và phân quyền',
      'route': Routes.roleManagement,
      'icon': Icons.admin_panel_settings_outlined,
      'category': 'Hệ thống'
    },
    {
      'title': 'Quản lý Phiên (Sessions)',
      'description': 'Phiên hoạt động của người dùng',
      'route': Routes.sessionManagement,
      'icon': Icons.devices_outlined,
      'category': 'Hệ thống'
    },
    {
      'title': 'Công cụ Dev',
      'description': 'Công cụ hỗ trợ nhà phát triển',
      'route': Routes.developerTool,
      'icon': Icons.developer_mode_outlined,
      'category': 'Hệ thống'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Provider.of<CustomerController>(context);
    final membershipController = Provider.of<MembershipController>(context);

    // Lọc các trang hệ thống
    final filteredPages = _systemPages.where((page) {
      final title = (page['title'] as String).toLowerCase();
      final desc = (page['description'] as String).toLowerCase();
      final cat = (page['category'] as String).toLowerCase();
      return title.contains(_query.toLowerCase()) ||
          desc.contains(_query.toLowerCase()) ||
          cat.contains(_query.toLowerCase());
    }).toList();

    // Lọc hội viên
    final filteredMembers = customerController.allMembers.where((member) {
      final name = member.fullName.toLowerCase();
      final email = member.email.toLowerCase();
      final phone = (member.phoneNumber ?? '').toLowerCase();
      return name.contains(_query.toLowerCase()) ||
          email.contains(_query.toLowerCase()) ||
          phone.contains(_query.toLowerCase());
    }).toList();

    // Lọc gói tập
    final filteredPlans = membershipController.plans.where((plan) {
      final name = plan.name.toLowerCase();
      final desc = plan.description.toLowerCase();
      return name.contains(_query.toLowerCase()) || desc.contains(_query.toLowerCase());
    }).toList();

    final hasResults = filteredPages.isNotEmpty || filteredMembers.isNotEmpty || filteredPlans.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 680,
          height: 550,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFFF6B35), size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0A192F), fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm chức năng, hội viên, gói tập...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.normal),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _query = val;
                          });
                        },
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ESC',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Result Area
              Expanded(
                child: !hasResults
                    ? _buildNoResultsView()
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        children: [
                          if (filteredPages.isNotEmpty) ...[
                            _buildSectionHeader('CHỨC NĂNG HỆ THỐNG', filteredPages.length),
                            ...filteredPages.map((page) => _buildPageItem(context, page)),
                            const SizedBox(height: 16),
                          ],
                          if (filteredMembers.isNotEmpty) ...[
                            _buildSectionHeader('HỘI VIÊN', filteredMembers.length),
                            ...filteredMembers.take(5).map((member) => _buildMemberItem(context, member, customerController)),
                            if (filteredMembers.length > 5)
                              _buildMoreIndicator(context, Routes.customerManagement, 'Xem tất cả ${filteredMembers.length} hội viên'),
                            const SizedBox(height: 16),
                          ],
                          if (filteredPlans.isNotEmpty) ...[
                            _buildSectionHeader('GÓI TẬP GYM', filteredPlans.length),
                            ...filteredPlans.map((plan) => _buildPlanItem(context, plan)),
                          ],
                        ],
                      ),
              ),
              
              // Footer / Help Tip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F).withValues(alpha: 0.03),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.keyboard_return, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('Chọn kết quả', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Text(
                      'Hệ thống quản lý GymManagament v1.0',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count kết quả',
              style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, Map<String, dynamic> page) {
    return _buildHoverableListTile(
      onTap: () {
        Navigator.pop(context);
        context.go(page['route'] as String);
      },
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
        child: Icon(page['icon'] as IconData, color: const Color(0xFFFF6B35), size: 20),
      ),
      title: page['title'] as String,
      subtitle: page['description'] as String,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          page['category'] as String,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, MemberModel member, CustomerController controller) {
    return _buildHoverableListTile(
      onTap: () {
        Navigator.pop(context);
        controller.selectMember(member);
        context.go(Routes.customerManagement);
      },
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF0A192F).withValues(alpha: 0.08),
        backgroundImage: member.profileImageUrl != null ? NetworkImage(member.profileImageUrl!) : null,
        child: member.profileImageUrl == null
            ? Text(
                member.fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: member.fullName,
      subtitle: member.email + (member.phoneNumber != null ? ' • ${member.phoneNumber}' : ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.membershipType,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.status == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.status == 'Active' ? 'Active' : 'Locked',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: member.status == 'Active' ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(BuildContext context, MembershipPlan plan) {
    return _buildHoverableListTile(
      onTap: () {
        Navigator.pop(context);
        context.go(Routes.membershipManagement);
      },
      leading: CircleAvatar(
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
        child: const Icon(Icons.card_membership, color: Colors.purple, size: 20),
      ),
      title: plan.name,
      subtitle: plan.description,
      trailing: Text(
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(plan.price),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 13),
      ),
    );
  }

  Widget _buildMoreIndicator(BuildContext context, String route, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 68, top: 4, bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 13, color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFF6B35)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy kết quả phù hợp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            'Thử tìm kiếm từ khóa khác hoặc kiểm tra chính tả.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverableListTile({
    required VoidCallback onTap,
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: const Color(0xFFFF6B35).withValues(alpha: 0.05),
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: trailing,
      ),
    );
  }
}
