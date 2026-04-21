import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/auth_provider.dart';
import '../../widget/loginAndSignInWidget/auth_background.dart';
import '../../widget/loginAndSignInWidget/auth_text_field.dart';
import '../../widget/loginAndSignInWidget/primary_button.dart';
import '../../widget/loginAndSignInWidget/status_card.dart';
import '../../widget/loginAndSignInWidget/step_indicator.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AuthProvider>();
    final hidden = context.select<AuthProvider, bool>((p) => p.signUpPasswordHidden);
    final agree = context.select<AuthProvider, bool>((p) => p.agreeTerms);
    final loading = context.select<AuthProvider, bool>((p) => p.loading);

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D1D1D),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    ),
                  ),
                  const Spacer(),
                  const StepIndicator(current: 1, total: 2),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'CREATE\nACCOUNT',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primarySoft,
                  height: 0.95,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 320,
                child: Text(
                  'Join the kinetic movement and track your elite performance.',
                  style: TextStyle(
                    color: Color(0xFFADADAD),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              AuthTextField(
                controller: provider.signUpNameController,
                label: 'FULL NAME',
                hint: 'ALEX RIVERA',
                suffix: const Icon(Icons.person, color: Color(0xFF696969)),
              ),
              const SizedBox(height: 22),
              AuthTextField(
                controller: provider.signUpEmailController,
                label: 'EMAIL ADDRESS',
                hint: 'ALEX@KINETIC.APP',
                keyboardType: TextInputType.emailAddress,
                suffix: const Icon(Icons.alternate_email, color: Color(0xFF696969)),
              ),
              const SizedBox(height: 22),
              AuthTextField(
                controller: provider.signUpPhoneController,
                label: 'PHONE NUMBER',
                hint: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                suffix: const Icon(Icons.smartphone, color: Color(0xFF696969)),
              ),
              const SizedBox(height: 22),
              AuthTextField(
                controller: provider.signUpPasswordController,
                label: 'PASSWORD',
                hint: '••••••••••••',
                obscureText: hidden,
                suffix: IconButton(
                  onPressed: provider.toggleSignUpPassword,
                  icon: Icon(
                    hidden ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF696969),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => provider.setAgreeTerms(!agree),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: agree ? AppColors.primary : const Color(0xFF242424),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: agree ? AppColors.primary : const Color(0xFF313131),
                          ),
                        ),
                        child: agree
                            ? const Icon(Icons.check, size: 16, color: Color(0xFF2D3300))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primarySoft,
                                ),
                              ),
                              TextSpan(
                                text: ' and ',
                                style: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primarySoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'CONTINUE',
                icon: Icons.arrow_forward,
                loading: loading,
                onPressed: () => provider.continueSignUp(context),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'LOG IN',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const StatusCard(),
            ],
          ),
        ),
      ),
    );
  }
}
