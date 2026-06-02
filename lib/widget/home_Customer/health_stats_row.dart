import 'package:flutter/material.dart';

class HealthStatsRow extends StatelessWidget {
  const HealthStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: WeightCard()),
        SizedBox(width: 20),
        Expanded(child: BmiCard()),
      ],
    );
  }
}

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.scale,
      iconColor: const Color(0xFFFF7051),
      title: 'WEIGHT',
      value: '84.5',
      suffix: 'KG',
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.73,
              minHeight: 8,
              backgroundColor: Color(0xFF202020),
              valueColor: AlwaysStoppedAnimation(Color(0xFFFF7051)),
            ),
          ),
        ],
      ),
    );
  }
}

class BmiCard extends StatelessWidget {
  const BmiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatCard(
      icon: Icons.monitor_heart_outlined,
      iconColor: Color(0xFFFFE74F),
      title: 'BMI',
      value: '23.1',
      suffix: '',
      bottom: Padding(
        padding: EdgeInsets.only(top: 28),
        child: Text(
          'NORMAL RANGE',
          style: TextStyle(
            color: Color(0xFFD8FF00),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.suffix,
    required this.bottom,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String suffix;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA9A9A9),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              if (suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    suffix,
                    style: const TextStyle(
                      color: Color(0xFFD8D8D8),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          bottom,
        ],
      ),
    );
  }
}

