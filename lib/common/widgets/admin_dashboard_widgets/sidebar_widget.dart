import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/route/routes.dart';
import '../../../controllers/auth_controller.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  bool _isMemberExpanded = true;
  bool _isOperationsExpanded = true;
  bool _isFinancialExpanded = true;
  bool _isContentExpanded = true;
  bool _isCommunicationExpanded = true;
  bool _isSystemExpanded = true;

  static const double _sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    // Lấy route hiện tại để highlight menu
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: _sidebarWidth,
      color: const Color(0xFF0A192F),
      child: Column(
        children: [
          _buildLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildGroup(
                    context,
                    title: "Tổng quan",
                    icon: Icons.dashboard,
                    isExpanded: true,
                    onToggle: null,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.dashboard, title: "Bảng điều khiển", route: Routes.adminDashboard),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Hội viên & Gói tập",
                    icon: Icons.card_membership,
                    isExpanded: _isMemberExpanded,
                    onToggle: () => setState(() => _isMemberExpanded = !_isMemberExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.card_membership, title: "Quản lý Gói tập", route: Routes.membershipManagement),
                      _NavItem(icon: Icons.group, title: "Quản lý Hội viên", route: Routes.customerManagement),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Vận hành & Tài sản",
                    icon: Icons.settings_suggest,
                    isExpanded: _isOperationsExpanded,
                    onToggle: () => setState(() => _isOperationsExpanded = !_isOperationsExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.badge, title: "Quản lý Nhân sự", route: Routes.personnelManagement),
                      _NavItem(icon: Icons.calendar_month, title: "Lịch làm việc", route: Routes.scheduleManagement),
                      _NavItem(icon: Icons.build, title: "Quản lý Thiết bị", route: Routes.equipmentManagement),
                      _NavItem(icon: Icons.store, title: "Quản lý Cửa hàng", route: Routes.storeManagement),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Tài chính & Doanh thu",
                    icon: Icons.monetization_on,
                    isExpanded: _isFinancialExpanded,
                    onToggle: () => setState(() => _isFinancialExpanded = !_isFinancialExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.analytics, title: "Báo cáo tài chính", route: Routes.financialManagement),
                      _NavItem(icon: Icons.payment, title: "Thanh toán hội viên", route: Routes.paymentManagement),
                      _NavItem(icon: Icons.paid, title: "Lương nhân sự", route: Routes.payrollManagement),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Quản lý Nội dung",
                    icon: Icons.article,
                    isExpanded: _isContentExpanded,
                    onToggle: () => setState(() => _isContentExpanded = !_isContentExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.post_add, title: "Bài viết & Tin tức", route: Routes.contentManagement),
                      _NavItem(icon: Icons.category, title: "Danh mục", route: Routes.categoryManagement),
                      _NavItem(icon: Icons.perm_media, title: "Thư viện Media", route: Routes.mediaManagement),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Truyền thông & Báo cáo",
                    icon: Icons.campaign,
                    isExpanded: _isCommunicationExpanded,
                    onToggle: () => setState(() => _isCommunicationExpanded = !_isCommunicationExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.notifications_active, title: "Thông báo đẩy", route: Routes.notificationManagement),
                      _NavItem(icon: Icons.feedback, title: "Phản hồi hội viên", route: Routes.feedbackManagement),
                      _NavItem(icon: Icons.report_problem, title: "Báo cáo vi phạm", route: Routes.reportManagement),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Hệ thống & Bảo mật",
                    icon: Icons.settings,
                    isExpanded: _isSystemExpanded,
                    onToggle: () => setState(() => _isSystemExpanded = !_isSystemExpanded),
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(icon: Icons.admin_panel_settings, title: "Phân quyền (Roles)", route: Routes.roleManagement),
                      _NavItem(icon: Icons.manage_accounts, title: "Quản lý Tài khoản", route: Routes.accountManagement),
                      _NavItem(icon: Icons.devices, title: "Quản lý Phiên (Sessions)", route: Routes.sessionManagement),
                      _NavItem(icon: Icons.developer_mode, title: "Công cụ Dev", route: Routes.developerTool),
                      _NavItem(icon: Icons.logout, title: "Đăng xuất", route: Routes.login),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, color: Color(0xFFFF6B35), size: 32),
          SizedBox(width: 12),
          Text(
            "GYM ADMIN",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, {required String title, required IconData icon, required bool isExpanded, required VoidCallback? onToggle, required String currentRoute, required List<_NavItem> items}) {
    final isActive = items.any((item) => item.route == currentRoute);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: title, icon: icon, isExpanded: isExpanded, isActive: isActive, onTap: onToggle),
        if (isExpanded) ...items.map((item) => _subMenuItem(context, item.icon, item.title, item.route, item.route == currentRoute)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionHeader({required String title, required IconData icon, required bool isExpanded, required bool isActive, required VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: isActive ? const Color(0xFFFF6B35).withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[300], size: 22),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.blueGrey[200], fontWeight: FontWeight.bold, fontSize: 13)),
        trailing: onTap == null ? null : Icon(isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: Colors.blueGrey[400], size: 18),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _subMenuItem(BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 16, top: 2, bottom: 2),
      decoration: BoxDecoration(color: isActive ? const Color(0xFFFF6B35).withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(icon, size: 18, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[400]),
        title: Text(title, style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[300], fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        onTap: () async {
          if (route == Routes.login) {
            await context.read<AuthController>().signOut();
          }
          if (context.mounted) {
            context.go(route);
          }
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final String route;
  const _NavItem({required this.icon, required this.title, required this.route});
}
