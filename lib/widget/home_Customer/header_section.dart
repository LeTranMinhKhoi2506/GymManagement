import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE9F6F8),
          child: Icon(
            Icons.person,
            size: 32,
            color: Color(0xFF0B6D7D),
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: Color(0xFFB5B5B5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'ALEX',
                style: TextStyle(
                  color: Color(0xFFF1FFD0),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.notifications,
          color: Color(0xFFF1FFD0),
          size: 26,
        ),
        SizedBox(width: 24),
        Text(
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

