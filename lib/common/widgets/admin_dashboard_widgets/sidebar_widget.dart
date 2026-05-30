import 'package:flutter/material.dart';
import '../../../app/route/routes.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  bool _isCollapsed = false;
  bool _isMemberExpanded = true;
  bool _isOperationsExpanded = true;
  bool _isBusinessExpanded = true;
  bool _isAssetsExpanded = true;
  bool _isSystemExpanded = true;

  static const double _expandedWidth = 250;
  static const double _collapsedWidth = 90;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isCollapsed = _isCollapsed;

    return AnimatedContainer(
      width: isCollapsed ? _collapsedWidth : _expandedWidth,
      duration: const Duration(milliseconds: 200),
      color: const Color(0xFF0A192F),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center,
                    color: Color(0xFFFF6B35), size: 30),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Text("GYM ADMIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildGroup(
                    context,
                    title: "Tổng quan",
                    icon: Icons.dashboard,
                    isExpanded: true,
                    onToggle: null,
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.dashboard,
                        title: "Bảng điều khiển",
                        route: Routes.adminDashboard,
                      ),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Quản lý hội viên",
                    icon: Icons.card_membership,
                    isExpanded: _isMemberExpanded,
                    onToggle: () =>
                        setState(() => _isMemberExpanded = !_isMemberExpanded),
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.card_membership,
                        title: "Gói tập",
                        route: Routes.membershipManagement,
                      ),
                      _NavItem(
                        icon: Icons.group,
                        title: "Khách hàng",
                        route: Routes.customerManagement,
                      ),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Vận hành",
                    icon: Icons.settings_suggest,
                    isExpanded: _isOperationsExpanded,
                    onToggle: () => setState(
                        () => _isOperationsExpanded = !_isOperationsExpanded),
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.badge,
                        title: "Nhân sự",
                        route: Routes.personnelManagement,
                      ),
                      _NavItem(
                        icon: Icons.calendar_month,
                        title: "Lịch làm việc",
                        route: Routes.scheduleManagement,
                      ),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Kinh doanh",
                    icon: Icons.trending_up,
                    isExpanded: _isBusinessExpanded,
                    onToggle: () =>
                        setState(() => _isBusinessExpanded = !_isBusinessExpanded),
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.shopping_bag,
                        title: "Cửa hàng",
                        route: Routes.storeManagement,
                      ),
                      _NavItem(
                        icon: Icons.trending_up,
                        title: "Tổng quan tài chính",
                        route: Routes.financialManagement,
                      ),
                      _NavItem(
                        icon: Icons.paid,
                        title: "Thanh toán hội viên",
                        route: Routes.paymentManagement,
                      ),
                      _NavItem(
                        icon: Icons.people,
                        title: "Lương nhân viên",
                        route: Routes.payrollManagement,
                      ),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Tài sản",
                    icon: Icons.build,
                    isExpanded: _isAssetsExpanded,
                    onToggle: () =>
                        setState(() => _isAssetsExpanded = !_isAssetsExpanded),
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.build,
                        title: "Thiết bị",
                        route: Routes.equipmentManagement,
                      ),
                    ],
                  ),
                  _buildGroup(
                    context,
                    title: "Hệ thống",
                    icon: Icons.settings,
                    isExpanded: _isSystemExpanded,
                    onToggle: () =>
                        setState(() => _isSystemExpanded = !_isSystemExpanded),
                    isCollapsed: isCollapsed,
                    currentRoute: currentRoute,
                    items: [
                      _NavItem(
                        icon: Icons.settings,
                        title: "Cài đặt",
                        route: "/settings",
                      ),
                      _NavItem(
                        icon: Icons.logout,
                        title: "Đăng xuất",
                        route: Routes.login,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              tooltip: isCollapsed ? "Mở rộng" : "Thu gọn",
              onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
              icon: Icon(
                isCollapsed
                    ? Icons.keyboard_double_arrow_right
                    : Icons.keyboard_double_arrow_left,
                color: Colors.blueGrey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback? onToggle,
    required bool isCollapsed,
    required String? currentRoute,
    required List<_NavItem> items,
  }) {
    final isActive = items.any((item) => item.route == currentRoute);

    if (isCollapsed) {
      return Column(
        children: items
            .map((item) => _collapsedIconItem(
                  context,
                  icon: item.icon,
                  title: item.title,
                  route: item.route,
                  isActive: item.route == currentRoute,
                ))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: title,
          icon: icon,
          isExpanded: isExpanded,
          isActive: isActive,
          onTap: onToggle,
        ),
        if (isExpanded)
          ...items.map((item) => _subMenuItem(
                context,
                item.icon,
                item.title,
                item.route,
                item.route == currentRoute,
              )),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFF6B35).withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading:
            Icon(icon, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.blueGrey,
                fontWeight: FontWeight.bold)),
        trailing: onTap == null
            ? null
            : Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey,
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _subMenuItem(
      BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 28, right: 16, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color:
            isActive ? const Color(0xFFFF6B35).withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        leading: Icon(icon,
            size: 20,
            color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[300]),
        title: Text(title,
            style: TextStyle(
                fontSize: 13,
                color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[300],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        onTap: () {
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _collapsedIconItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Tooltip(
      message: title,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon,
              color:
                  isActive ? const Color(0xFFFF6B35) : Colors.blueGrey[300]),
          onPressed: () {
            if (!isActive) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final String route;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}
