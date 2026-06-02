import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/route/routes.dart';
import '../../provider/auth_provider.dart';
import '../../widget/loginAndSignInWidget/auth_background.dart';
import '../../widget/loginAndSignInWidget/auth_text_field.dart';
import '../../widget/loginAndSignInWidget/brand_logo.dart';
import '../../widget/loginAndSignInWidget/divider_text.dart';
import '../../widget/loginAndSignInWidget/primary_button.dart';
import '../../widget/loginAndSignInWidget/social_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AuthProvider>();
    final loginHidden = context.select<AuthProvider, bool>((p) => p.loginPasswordHidden);
    final loading = context.select<AuthProvider, bool>((p) => p.loading);

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
                  controller: provider.loginEmailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                AuthTextField(
                  controller: provider.loginPasswordController,
                  hint: 'Password',
                  obscureText: loginHidden,
                  suffix: IconButton(
                    onPressed: provider.toggleLoginPassword,
                    icon: Icon(
                      loginHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: const Color(0xFF696969),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: loading ? null : () => provider.sendPasswordReset(context),
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
                  onPressed: () => context.read<AuthProvider>().signIn(context),
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
                      leading: const Icon(Icons.apple, color: AppColors.text, size: 30),
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
