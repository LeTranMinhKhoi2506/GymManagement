import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/staff_controller.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/store_controller.dart';
import '../controllers/membership_controller.dart';
import '../controllers/financial_controller.dart';
import '../controllers/payment_controller.dart';
import '../controllers/payroll_controller.dart';
import '../controllers/equipment_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/feedback_controller.dart';
import '../controllers/content_controller.dart';
import '../controllers/role_controller.dart';
import '../controllers/report_controller.dart';
import '../controllers/media_controller.dart';
import '../controllers/session_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/user_controller.dart';
import '../provider/auth_provider.dart';
import '../provider/home_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => StaffController()),
        ChangeNotifierProvider(create: (_) => ScheduleController()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        ChangeNotifierProvider(create: (_) => StoreController()),
        ChangeNotifierProvider(create: (_) => MembershipController()),
        ChangeNotifierProvider(create: (_) => FinancialController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(create: (_) => PayrollController()),
        ChangeNotifierProvider(create: (_) => EquipmentController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => FeedbackController()),
        ChangeNotifierProvider(create: (_) => ContentController()),
        ChangeNotifierProvider(create: (_) => RoleController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => MediaController()),
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ];
}
