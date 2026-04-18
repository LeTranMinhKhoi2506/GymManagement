import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.center = true});

  final bool center;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          'KINETIC',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -1,
            color: AppColors.primarySoft,
            height: 1,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'FUEL YOUR AMBITION',
          style: TextStyle(
            color: Color(0xFF9F9F9F),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ],
    );

    return center ? Center(child: child) : child;
  }
}
