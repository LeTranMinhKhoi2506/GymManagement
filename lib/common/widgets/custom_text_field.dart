import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: AppStyles.inputDecoration(label, icon).copyWith(
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
