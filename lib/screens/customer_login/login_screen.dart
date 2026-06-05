import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/route/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/user_model.dart';
import '../../widget/loginAndSignInWidget/auth_background.dart';
import '../../widget/loginAndSignInWidget/auth_text_field.dart';
import '../../widget/loginAndSignInWidget/brand_logo.dart';
import '../../widget/loginAndSignInWidget/divider_text.dart';
import '../../widget/loginAndSignInWidget/primary_button.dart';
import '../../widget/loginAndSignInWidget/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAlreadyLoggedIn();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _redirectIfAlreadyLoggedIn() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || !mounted) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!mounted) return;

    final route = doc.exists
        ? Routes.dashboardForUser(
            UserModel.fromMap({
              ...(doc.data() ?? <String, dynamic>{}),
              'uid': doc.id,
            }),
          )
        : Routes.customerHome;
    context.go(route);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authController = context.read<AuthController>();
    final result = await authController.signIn(email, password);

    if (!mounted) return;

    if (result['status'] == 'success') {
      final user = authController.currentUser;
      final targetRoute =
          (result['route'] as String?) ?? Routes.dashboardForUser(user);

      context.go(targetRoute);
      _showSnackBar('Chào mừng ${user?.fullName ?? 'bạn'}!', Colors.green);
    } else {
      _showSnackBar(
        result['message']?.toString() ?? 'Lỗi đăng nhập',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthController, bool>((p) => p.isLoading);

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 70,
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                const BrandLogo(),
                const SizedBox(height: 58),
                AuthTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: const Color(0xFF696969),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final email = _emailController.text.trim();
                            final message = await context
                                .read<AuthController>()
                                .resetPassword(email);
                            if (!context.mounted) return;
                            if (message == 'success') {
                              _showSnackBar(
                                'Đã gửi email đặt lại mật khẩu.',
                                Colors.green,
                              );
                            } else {
                              _showSnackBar(
                                message ?? 'Không thể gửi email lúc này.',
                                Colors.red,
                              );
                            }
                          },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primarySoft,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'SIGN IN',
                  loading: loading,
                  onPressed: loading ? null : _submit,
                ),
                const SizedBox(height: 52),
                const DividerText(text: 'OR CONTINUE WITH'),
                const SizedBox(height: 32),
                Row(
                  children: [
                    SocialButton(
                      label: 'Google',
                      leading: const GoogleMark(),
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    SocialButton(
                      label: 'Apple',
                      leading: const Icon(
                        Icons.apple,
                        color: AppColors.text,
                        size: 30,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => context.push(Routes.customerSignup),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primarySoft,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
                Center(
                  child: SizedBox(
                    width: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _MiniBar(color: Color(0xFF4B4B4B), height: 34),
                        _MiniBar(color: Color(0xFF738800), height: 50),
                        _MiniBar(color: Color(0xFF4B4B4B), height: 44),
                        _MiniBar(color: Color(0xFF803C1F), height: 38),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
