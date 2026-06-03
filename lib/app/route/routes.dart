import 'package:go_router/go_router.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/admins/dashboard/admin_dashboard_screen.dart';
import '../../screens/admins/operations/personnel_management_screen.dart';
import '../../screens/admins/operations/schedule_management_screen.dart';
import '../../screens/admins/members/customer_management_screen.dart';
import '../../screens/admins/operations/store_management_screen.dart';
import '../../screens/admins/members/membership_management_screen.dart';
import '../../screens/admins/financials/financial_management_screen.dart';
import '../../screens/admins/financials/payment_management_screen.dart';
import '../../screens/admins/financials/payroll_management_screen.dart';
import '../../screens/admins/operations/equipment_management_screen.dart';
import '../../screens/admins/communications/notification_management_screen.dart';
import '../../screens/admins/communications/feedback_management_screen.dart';
import '../../screens/admins/content/content_management_screen.dart';
import '../../screens/admins/content/category_management_screen.dart';
import '../../screens/admins/system/role_management_screen.dart';
import '../../screens/admins/communications/report_management_screen.dart';
import '../../screens/admins/content/media_management_screen.dart';
import '../../screens/admins/system/session_management_screen.dart';
import '../../screens/admins/system/developer_tool_screen.dart';
import '../../screens/admins/system/account_management_screen.dart';
import '../../screens/PT/pt_dashboard_screen.dart';
import '../../screens/PT/pt_schedule_screen.dart';
import '../../screens/PT/pt_student_management_screen.dart';
import '../../screens/PT/pt_income_screen.dart';
import '../../screens/PT/pt_class_registration_screen.dart';

// Receptionist Screens
import '../../screens/receptionist/receptionist_dashboard_screen.dart';
import '../../screens/receptionist/receptionist_checkin_screen.dart';
import '../../screens/receptionist/receptionist_pos_screen.dart';
import '../../screens/receptionist/receptionist_support_screen.dart';
import '../../screens/receptionist/receptionist_facility_screen.dart';
import '../../screens/customer_home/customer_home_screen.dart';
import '../../screens/customer_login/login_screen.dart' as customer_login;
import '../../screens/customer_login/signup_screen.dart' as customer_signup;

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerLogin = '/customer-login';
  static const String customerSignup = '/customer-signup';
  static const String customerHome = '/customer-home';
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
  static const String developerTool = '/developer-tool';
  static const String accountManagement = '/account-management';

  // PT Routes
  static const String ptDashboard = '/pt-dashboard';
  static const String ptSchedule = '/pt-schedule';
  static const String ptStudentManagement = '/pt-student-management';
  static const String ptIncome = '/pt-income';
  static const String ptClassRegistration = '/pt-class-registration';

  // Receptionist Routes
  static const String receptionistDashboard = '/receptionist-dashboard';
  static const String receptionistCheckIn = '/receptionist-checkin';
  static const String receptionistPOS = '/receptionist-pos';
  static const String receptionistSupport = '/receptionist-support';
  static const String receptionistFacility = '/receptionist-facility';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: signup, builder: (context, state) => const SignUpScreen()),
      GoRoute(path: customerLogin, builder: (context, state) => const customer_login.LoginScreen()),
      GoRoute(path: customerSignup, builder: (context, state) => const customer_signup.SignUpScreen()),
      GoRoute(path: customerHome, builder: (context, state) => const CustomerHomeScreen()),
      GoRoute(path: forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: personnelManagement, builder: (context, state) => const PersonnelManagementScreen()),
      GoRoute(path: scheduleManagement, builder: (context, state) => const ScheduleManagementScreen()),
      GoRoute(path: customerManagement, builder: (context, state) => const CustomerManagementScreen()),
      GoRoute(path: storeManagement, builder: (context, state) => const StoreManagementScreen()),
      GoRoute(path: membershipManagement, builder: (context, state) => const MembershipManagementScreen()),
      GoRoute(path: financialManagement, builder: (context, state) => const FinancialManagementScreen()),
      GoRoute(path: paymentManagement, builder: (context, state) => const PaymentManagementScreen()),
      GoRoute(path: payrollManagement, builder: (context, state) => const PayrollManagementScreen()),
      GoRoute(path: equipmentManagement, builder: (context, state) => const EquipmentManagementScreen()),
      GoRoute(path: notificationManagement, builder: (context, state) => const NotificationManagementScreen()),
      GoRoute(path: feedbackManagement, builder: (context, state) => const FeedbackManagementScreen()),
      GoRoute(path: contentManagement, builder: (context, state) => const ContentManagementScreen()),
      GoRoute(path: categoryManagement, builder: (context, state) => const CategoryManagementScreen()),
      GoRoute(path: roleManagement, builder: (context, state) => const RoleManagementScreen()),
      GoRoute(path: reportManagement, builder: (context, state) => const ReportManagementScreen()),
      GoRoute(path: mediaManagement, builder: (context, state) => const MediaManagementScreen()),
      GoRoute(path: sessionManagement, builder: (context, state) => const SessionManagementScreen()),
      GoRoute(path: developerTool, builder: (context, state) => const DeveloperToolScreen()),
      GoRoute(path: accountManagement, builder: (context, state) => const AccountManagementScreen()),
      
      // PT Routes
      GoRoute(path: ptDashboard, builder: (context, state) => const PtDashboardScreen()),
      GoRoute(path: ptSchedule, builder: (context, state) => const PtScheduleScreen()),
      GoRoute(path: ptStudentManagement, builder: (context, state) => const PtStudentManagementScreen()),
      GoRoute(path: ptIncome, builder: (context, state) => const PtIncomeScreen()),
      GoRoute(path: ptClassRegistration, builder: (context, state) => const PtClassRegistrationScreen()),

      // Receptionist Routes
      GoRoute(path: receptionistDashboard, builder: (context, state) => const ReceptionistDashboardScreen()),
      GoRoute(path: receptionistCheckIn, builder: (context, state) => const ReceptionistCheckInScreen()),
      GoRoute(path: receptionistPOS, builder: (context, state) => const ReceptionistPOSScreen()),
      GoRoute(path: receptionistSupport, builder: (context, state) => const ReceptionistSupportScreen()),
      GoRoute(path: receptionistFacility, builder: (context, state) => const ReceptionistFacilityScreen()),
    ],
  );
}
