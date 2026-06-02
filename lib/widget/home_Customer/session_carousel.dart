import 'package:flutter/material.dart';

class SessionCarousel extends StatelessWidget {
  const SessionCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: const [
          YogaSessionCard(),
          SizedBox(width: 20),
          SideSessionCard(),
        ],
      ),
    );
  }
}

class YogaSessionCard extends StatelessWidget {
  const YogaSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 396,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F0D7),
            Color(0xFFE7DFC1),
            Color(0xFF191919),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            bottom: 24,
            child: Opacity(
              opacity: 0.65,
              child: Icon(
                Icons.self_improvement,
                size: 160,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
          Positioned(
            right: 46,
            bottom: 34,
            child: Opacity(
              opacity: 0.55,
              child: Icon(
                Icons.spa,
                size: 140,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 96,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE74F),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'NEW SESSION',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 30,
            bottom: 54,
            child: Text(
              'ZEN FLOW YOGA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
          const Positioned(
            left: 30,
            bottom: 32,
            child: Text(
              'Monday • 07:00 AM • Studio B',
              style: TextStyle(
                color: Color(0xFFD8D8D8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SideSessionCard extends StatelessWidget {
  const SideSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7D281F), Color(0xFF220C0A)],
        ),
      ),
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          'STRENGTH',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

