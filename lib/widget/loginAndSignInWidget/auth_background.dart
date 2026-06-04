import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: Alignment(0, 1.1),
          radius: 1.2,
          colors: [
            Color(0x332F1B00),
            Color(0x220D1400),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 80,
            right: -40,
            child: _GlowOrb(
              size: 180,
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -30,
            child: _GlowOrb(
              size: 160,
              color: Colors.orange.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 70,
              spreadRadius: 28,
            ),
          ],
        ),
      ),
    );
  }
}
