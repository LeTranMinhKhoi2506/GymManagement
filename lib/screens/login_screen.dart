import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../common/styles/app_styles.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_text_field.dart';
import '../app/route/Routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final authController = Provider.of<AuthController>(context, listen: false);
      
      Map<String, dynamic> result = await authController.signIn(_email, _password);

      if (result['status'] == 'success') {
        final user = authController.currentUser;
        if (kIsWeb && user?.role != 'admin') {
          await authController.signOut();
          _showSnackBar("Tài khoản không có quyền Admin.", Colors.red);
        } else if (!kIsWeb && user?.role != 'user') {
          await authController.signOut();
          _showSnackBar("Vui lòng dùng App cho Thành viên.", Colors.red);
        } else {
          _showSnackBar("Chào mừng ${user?.fullName}!", Colors.green);
          
          // ĐIỀU HƯỚNG DỰA TRÊN ROLE
          if (user?.role == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.adminDashboard);
          } else {
            // Navigator.pushReplacementNamed(context, Routes.userHome);
          }
        }
      } else {
        _showSnackBar(result['message'] ?? "Lỗi đăng nhập", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: AppStyles.containerDecoration,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center, size: 70, color: AppStyles.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    kIsWeb ? "ADMIN PORTAL" : "GYM MEMBER",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) => _email = val.trim(),
                    onSaved: (val) => _email = val!.trim(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Vui lòng nhập email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: "Mật khẩu",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    onChanged: (val) => _password = val,
                    onSaved: (val) => _password = val!,
                    validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, 
                      child: const Text("Quên mật khẩu?", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    text: "ĐĂNG NHẬP",
                    isLoading: authController.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.signup),
                        child: const Text("Đăng ký", style: TextStyle(fontWeight: FontWeight.bold, color: AppStyles.primaryColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
