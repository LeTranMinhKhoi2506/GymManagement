import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/admins/admin_dashboard_screen.dart';
import '../../screens/admins/personnel_management_screen.dart';
import '../../screens/admins/schedule_management_screen.dart';
import '../../screens/admins/customer_management_screen.dart';
import '../../screens/admins/store_management_screen.dart';
import '../../screens/admins/membership_management_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminDashboard = '/admin-dashboard';
  static const String personnelManagement = '/personnel-management';
  static const String scheduleManagement = '/schedule-management';
  static const String customerManagement = '/customer-management';
  static const String storeManagement = '/store-management';
  static const String membershipManagement = '/membership-management';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      personnelManagement: (context) => const PersonnelManagementScreen(),
      scheduleManagement: (context) => const ScheduleManagementScreen(),
      customerManagement: (context) => const CustomerManagementScreen(),
      storeManagement: (context) => const StoreManagementScreen(),
      membershipManagement: (context) => const MembershipManagementScreen(),
    };
  }
}
