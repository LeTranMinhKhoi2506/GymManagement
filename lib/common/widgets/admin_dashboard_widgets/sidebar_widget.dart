import 'package:flutter/material.dart';
import '../../../app/route/routes.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  bool _isFinancialExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      width: 250,
      color: const Color(0xFF0A192F),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, color: Color(0xFFFF6B35), size: 30),
                SizedBox(width: 12),
                Text("GYM ADMIN",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
          _sidebarItem(context, Icons.dashboard, "Bảng điều khiển", Routes.adminDashboard, currentRoute == Routes.adminDashboard),
          _sidebarItem(context, Icons.card_membership, "Gói tập", Routes.membershipManagement, currentRoute == Routes.membershipManagement),
          _sidebarItem(context, Icons.badge, "Nhân sự", Routes.personnelManagement, currentRoute == Routes.personnelManagement),
          _sidebarItem(context, Icons.calendar_month, "Lịch làm việc", Routes.scheduleManagement, currentRoute == Routes.scheduleManagement),
          _sidebarItem(context, Icons.group, "Khách hàng", Routes.customerManagement, currentRoute == Routes.customerManagement),
          _sidebarItem(context, Icons.shopping_bag, "Cửa hàng", Routes.storeManagement, currentRoute == Routes.storeManagement),
          _buildFinancialMenu(context, currentRoute),
          _sidebarItem(context, Icons.build, "Thiết bị", "/equipment", false),
          _sidebarItem(context, Icons.settings, "Cài đặt", "/settings", false),
          const Spacer(),
          _sidebarItem(context, Icons.logout, "Đăng xuất", Routes.login, false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFinancialMenu(BuildContext context, String? currentRoute) {
    final isFinancialActive = currentRoute == Routes.financialManagement ||
        currentRoute == Routes.paymentManagement ||
        currentRoute == Routes.payrollManagement;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: (isFinancialActive || _isFinancialExpanded)
                ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.payments,
                color: (isFinancialActive || _isFinancialExpanded)
                    ? const Color(0xFFFF6B35)
                    : Colors.blueGrey),
            title: Text("Tài chính",
                style: TextStyle(
                    color: (isFinancialActive || _isFinancialExpanded)
                        ? Colors.white
                        : Colors.blueGrey,
                    fontWeight: (isFinancialActive || _isFinancialExpanded)
                        ? FontWeight.bold
                        : FontWeight.normal)),
            trailing: Icon(
              _isFinancialExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              color: (isFinancialActive || _isFinancialExpanded)
                  ? const Color(0xFFFF6B35)
                  : Colors.blueGrey,
            ),
            onTap: () {
              setState(() {
                _isFinancialExpanded = !_isFinancialExpanded;
              });
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_isFinancialExpanded)
          _subMenuItem(
            context,
            Icons.trending_up,
            "Tổng Quan Tài Chính",
            Routes.financialManagement,
            currentRoute == Routes.financialManagement,
          ),
        if (_isFinancialExpanded)
          _subMenuItem(
            context,
            Icons.paid,
            "Thanh Toán Hội Viên",
            Routes.paymentManagement,
            currentRoute == Routes.paymentManagement,
          ),
        if (_isFinancialExpanded)
          _subMenuItem(
            context,
            Icons.people,
            "Lương Nhân Viên",
            Routes.payrollManagement,
            currentRoute == Routes.payrollManagement,
          ),
      ],
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B35).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFFFF6B35) : Colors.blueGrey),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.blueGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _subMenuItem(BuildContext context, IconData icon, String title,
      String route, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 16, top: 4, bottom: 4),
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
}
