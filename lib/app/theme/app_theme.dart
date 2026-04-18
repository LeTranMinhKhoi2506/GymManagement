import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF060707);
  static const Color card = Color(0xFF141414);
  static const Color input = Color(0xFF0D0D0D);
  static const Color primary = Color(0xFFD7FF00);
  static const Color primarySoft = Color(0xFFE8F0BF);
  static const Color text = Color(0xFFF5F5F5);
  static const Color hint = Color(0xFF8B8B8B);
  static const Color muted = Color(0xFF6F6F6F);
  static const Color line = Color(0xFF2A2A2A);
  static const Color orange = Color(0xFFFF7A45);
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.orange,
        surface: AppColors.card,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      ),
    );
  }
}
