import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: icon != null 
        ? AppStyles.inputDecoration(label, icon!).copyWith(
            hintText: hintText,
            suffixIcon: suffixIcon,
          )
        : InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: suffixIcon,
          ),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
