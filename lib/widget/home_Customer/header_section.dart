import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE9F6F8),
          child: Icon(
            Icons.person,
            size: 32,
            color: Color(0xFF0B6D7D),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: Color(0xFFB5B5B5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  final fullName = user?.displayName ?? (user?.email?.split('@').first ?? 'USER');
                  return Text(
                    fullName.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFF1FFD0),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Icon(
          Icons.notifications,
          color: Color(0xFFF1FFD0),
          size: 26,
        ),
        const SizedBox(width: 24),
        const Text(
          'KINETIC',
          style: TextStyle(
            color: Color(0xFFF1FFD0),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

