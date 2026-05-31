import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/admins/admin_dashboard_screen.dart';
import '../../screens/admins/personnel_management_screen.dart';
import '../../screens/admins/schedule_management_screen.dart';
import '../../screens/admins/customer_management_screen.dart';
import '../../screens/admins/store_management_screen.dart';
import '../../screens/admins/membership_management_screen.dart';
import '../../screens/admins/financial_management_screen.dart';
import '../../screens/admins/payment_management_screen.dart';
import '../../screens/admins/payroll_management_screen.dart';
import '../../screens/admins/equipment_management_screen.dart';
import '../../screens/admins/notification_management_screen.dart';
import '../../screens/admins/feedback_management_screen.dart';
import '../../screens/admins/content_management_screen.dart';
import '../../screens/admins/category_management_screen.dart';
import '../../screens/admins/role_management_screen.dart';
import '../../screens/admins/report_management_screen.dart';
import '../../screens/admins/media_management_screen.dart';
import '../../screens/admins/session_management_screen.dart';
import '../../screens/PT/pt_dashboard_screen.dart';
import '../../screens/PT/pt_schedule_screen.dart';
import '../../screens/PT/pt_student_management_screen.dart';
import '../../screens/PT/pt_income_screen.dart';
import '../../screens/PT/pt_class_registration_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String adminDashboard = '/admin-dashboard';
  static const String personnelManagement = '/personnel-management';
  static const String scheduleManagement = '/schedule-management';
  static const String customerManagement = '/customer-management';
  static const String storeManagement = '/store-management';
  static const String membershipManagement = '/membership-management';
  static const String financialManagement = '/financial-management';
  static const String paymentManagement = '/payment-management';
  static const String payrollManagement = '/payroll-management';
  static const String equipmentManagement = '/equipment-management';
  static const String notificationManagement = '/notification-management';
  static const String feedbackManagement = '/feedback-management';
  static const String contentManagement = '/content-management';
  static const String categoryManagement = '/category-management';
  static const String roleManagement = '/role-management';
  static const String reportManagement = '/report-management';
  static const String mediaManagement = '/media-management';
  static const String sessionManagement = '/session-management';

  // PT Routes
  static const String ptDashboard = '/pt-dashboard';
  static const String ptSchedule = '/pt-schedule';
  static const String ptStudentManagement = '/pt-student-management';
  static const String ptIncome = '/pt-income';
  static const String ptClassRegistration = '/pt-class-registration';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      personnelManagement: (context) => const PersonnelManagementScreen(),
      scheduleManagement: (context) => const ScheduleManagementScreen(),
      customerManagement: (context) => const CustomerManagementScreen(),
      storeManagement: (context) => const StoreManagementScreen(),
      membershipManagement: (context) => const MembershipManagementScreen(),
      financialManagement: (context) => const FinancialManagementScreen(),
      paymentManagement: (context) => const PaymentManagementScreen(),
      payrollManagement: (context) => const PayrollManagementScreen(),
      equipmentManagement: (context) => const EquipmentManagementScreen(),
      notificationManagement: (context) => const NotificationManagementScreen(),
      feedbackManagement: (context) => const FeedbackManagementScreen(),
      contentManagement: (context) => const ContentManagementScreen(),
      categoryManagement: (context) => const CategoryManagementScreen(),
      roleManagement: (context) => const RoleManagementScreen(),
      reportManagement: (context) => const ReportManagementScreen(),
      mediaManagement: (context) => const MediaManagementScreen(),
      sessionManagement: (context) => const SessionManagementScreen(),
      
      // PT Routes
      ptDashboard: (context) => const PtDashboardScreen(),
      ptSchedule: (context) => const PtScheduleScreen(),
      ptStudentManagement: (context) => const PtStudentManagementScreen(),
      ptIncome: (context) => const PtIncomeScreen(),
      ptClassRegistration: (context) => const PtClassRegistrationScreen(),
    };
  }
}
