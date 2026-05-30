import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../common/styles/app_styles.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final authController = Provider.of<AuthController>(context, listen: false);
      String role = kIsWeb ? 'admin' : 'user';

      String? result = await authController.signUp(
        email: _email,
        password: _password,
        fullName: _fullName,
        role: role,
      );

      if (!mounted) return;
      if (result == "success") {
        _showSuccessDialog("Đăng ký thành công", "Vui lòng kiểm tra email để xác thực tài khoản.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? "Lỗi đăng ký"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryColor, foregroundColor: Colors.white),
            child: const Text("Đã hiểu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(kIsWeb ? "Đăng ký Admin" : "Đăng ký Thành viên"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32.0),
            decoration: AppStyles.containerDecoration,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  const Icon(Icons.person_add_rounded, size: 70, color: AppStyles.primaryColor),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: "Họ và Tên",
                    icon: Icons.person,
                    onChanged: (val) => _fullName = val.trim(),
                    onSaved: (val) => _fullName = val!.trim(),
                    validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 16),
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
                    validator: (val) => (val != null && val.length < 6) ? 'Mật khẩu phải từ 6 ký tự' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: "ĐĂNG KÝ NGAY",
                    isLoading: authController.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(color: AppStyles.primaryColor)),
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
