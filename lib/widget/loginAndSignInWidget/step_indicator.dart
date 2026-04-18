import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'STEP $current OF $total',
          style: const TextStyle(
            color: AppColors.primarySoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            final active = index < current;
            return Container(
              width: 40,
              height: 6,
              margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: active ? AppColors.primarySoft : const Color(0xFF2E2E2E),
              ),
            );
          }),
        ),
      ],
    );
  }
}
