import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_model.dart';
import '../../screens/PT/pt_class_registration_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/PT/pt_main_layout.dart';
import '../../screens/receptionist/receptionist_main_layout.dart';
import '../../screens/receptionist/swipable_shell_container.dart';
import '../../screens/PT/pt_dashboard_screen.dart';
import '../../screens/PT/pt_income_screen.dart';
import '../../screens/PT/pt_schedule_screen.dart';
import '../../screens/PT/pt_student_management_screen.dart';
import '../../screens/admins/communications/feedback_management_screen.dart';
import '../../screens/admins/communications/notification_management_screen.dart';
import '../../screens/admins/communications/report_management_screen.dart';
import '../../screens/admins/content/category_management_screen.dart';
import '../../screens/admins/content/content_management_screen.dart';
import '../../screens/admins/content/media_management_screen.dart';
import '../../screens/admins/dashboard/admin_dashboard_screen.dart';
import '../../screens/admins/financials/financial_management_screen.dart';
import '../../screens/admins/financials/payment_management_screen.dart';
import '../../screens/admins/financials/payroll_management_screen.dart';
import '../../screens/admins/members/customer_management_screen.dart';
import '../../screens/admins/members/membership_management_screen.dart';
import '../../screens/admins/operations/equipment_management_screen.dart';
import '../../screens/admins/operations/personnel_management_screen.dart';
import '../../screens/admins/operations/schedule_management_screen.dart';
import '../../screens/admins/operations/store_management_screen.dart';
import '../../screens/admins/system/role_management_screen.dart';
import '../../screens/admins/system/session_management_screen.dart';
import '../../screens/admins/system/account_management_screen.dart';
import '../../screens/admins/system/developer_tool_screen.dart';
import '../../screens/customer_home/customer_home_screen.dart';
import '../../screens/customer_home/social_feed/notifications_screen.dart';
import '../../screens/customer_home/social_feed/search_screen.dart';
import '../../screens/customer_home/social_feed/user_profile_screen.dart';
import '../../screens/customer_login/login_screen.dart' as customer_login;
import '../../screens/customer_login/signup_screen.dart' as customer_signup;
import '../../screens/forgot_password_screen.dart';
import '../../screens/receptionist/receptionist_checkin_screen.dart';
import '../../screens/receptionist/receptionist_dashboard_screen.dart';
import '../../screens/receptionist/receptionist_facility_screen.dart';
import '../../screens/receptionist/receptionist_pos_screen.dart';
import '../../screens/receptionist/receptionist_support_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerLogin = '/customer_login';
  static const String customerSignup = '/customer-signup';
  static const String customerHome = '/customer-home';
  static const String socialSearch = '/social-search';
  static const String socialNotifications = '/social-notifications';
  static const String userProfile = '/user-profile';
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
  static const String accountManagement = '/account-management';
  static const String developerTool = '/developer-tool';

  static const String ptDashboard = '/pt-dashboard';
  static const String ptSchedule = '/pt-schedule';
  static const String ptStudentManagement = '/pt-student-management';
  static const String ptIncome = '/pt-income';
  static const String ptClassRegistration = '/pt-class-registration';
  static const String chat = '/chat';

  static const String receptionistDashboard = '/receptionist-dashboard';
  static const String receptionistCheckIn = '/receptionist-checkin';
  static const String receptionistPOS = '/receptionist-pos';
  static const String receptionistSupport = '/receptionist-support';
  static const String receptionistFacility = '/receptionist-facility';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;
      final isAuthPage =
          location == login ||
              location == customerLogin ||
              location == signup ||
              location == customerSignup ||
              location == forgotPassword;

      if (user == null) {
        return isAuthPage ? null : login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const customer_login.LoginScreen(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const customer_signup.SignUpScreen(),
      ),
      GoRoute(
        path: customerLogin,
        builder: (context, state) => const customer_login.LoginScreen(),
      ),
      GoRoute(
        path: customerSignup,
        builder: (context, state) => const customer_signup.SignUpScreen(),
      ),
      GoRoute(
        path: customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: socialSearch,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: socialNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '$userProfile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: personnelManagement,
        builder: (context, state) => const PersonnelManagementScreen(),
      ),
      GoRoute(
        path: scheduleManagement,
        builder: (context, state) => const ScheduleManagementScreen(),
      ),
      GoRoute(
        path: customerManagement,
        builder: (context, state) => const CustomerManagementScreen(),
      ),
      GoRoute(
        path: storeManagement,
        builder: (context, state) => const StoreManagementScreen(),
      ),
      GoRoute(
        path: membershipManagement,
        builder: (context, state) => const MembershipManagementScreen(),
      ),
      GoRoute(
        path: financialManagement,
        builder: (context, state) => const FinancialManagementScreen(),
      ),
      GoRoute(
        path: paymentManagement,
        builder: (context, state) => const PaymentManagementScreen(),
      ),
      GoRoute(
        path: payrollManagement,
        builder: (context, state) => const PayrollManagementScreen(),
      ),
      GoRoute(
        path: equipmentManagement,
        builder: (context, state) => const EquipmentManagementScreen(),
      ),
      GoRoute(
        path: notificationManagement,
        builder: (context, state) => const NotificationManagementScreen(),
      ),
      GoRoute(
        path: feedbackManagement,
        builder: (context, state) => const FeedbackManagementScreen(),
      ),
      GoRoute(
        path: contentManagement,
        builder: (context, state) => const ContentManagementScreen(),
      ),
      GoRoute(
        path: categoryManagement,
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: roleManagement,
        builder: (context, state) => const RoleManagementScreen(),
      ),
      GoRoute(
        path: reportManagement,
        builder: (context, state) => const ReportManagementScreen(),
      ),
      GoRoute(
        path: mediaManagement,
        builder: (context, state) => const MediaManagementScreen(),
      ),
      GoRoute(
        path: sessionManagement,
        builder: (context, state) => const SessionManagementScreen(),
      ),
      GoRoute(
        path: accountManagement,
        builder: (context, state) => const AccountManagementScreen(),
      ),
      GoRoute(
        path: developerTool,
        builder: (context, state) => const DeveloperToolScreen(),
      ),
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SwipableShellContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return PtMainLayout(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ptDashboard,
                builder: (context, state) => const PtDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ptSchedule,
                builder: (context, state) => const PtScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ptStudentManagement,
                builder: (context, state) => const PtStudentManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ptIncome,
                builder: (context, state) => const PtIncomeScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: ptClassRegistration,
        builder: (context, state) => const PtClassRegistrationScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) {
          final chatRoomId = state.uri.queryParameters['chatRoomId'] ?? '';
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          final otherUserName = state.uri.queryParameters['otherUserName'] ?? '';
          return ChatScreen(
            chatRoomId: chatRoomId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          );
        },
      ),
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SwipableShellContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return ReceptionistMainLayout(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: receptionistDashboard,
                builder: (context, state) => const ReceptionistDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: receptionistCheckIn,
                builder: (context, state) => const ReceptionistCheckInScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: receptionistPOS,
                builder: (context, state) => const ReceptionistPOSScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: receptionistSupport,
                builder: (context, state) => const ReceptionistSupportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: receptionistFacility,
                builder: (context, state) => const ReceptionistFacilityScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static String dashboardForUser(UserModel? user) {
    if (user == null) return customerHome;

    final role = user.role.toLowerCase().trim();
    final position = (user.position ?? '').toLowerCase().trim();

    if (role == 'admin') return adminDashboard;
    if (role == 'trainer' || position == 'trainer') return ptDashboard;
    if (role == 'receptionist' ||
        role == 'staff' ||
        position == 'receptionist') {
      return receptionistDashboard;
    }
    return customerHome;
  }
}
