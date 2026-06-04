import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class DividerText extends StatelessWidget {
  const DividerText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9A9A9A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.4,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
      ],
    );
  }
}
