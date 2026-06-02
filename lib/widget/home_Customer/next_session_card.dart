import 'package:flutter/material.dart';

class NextSessionCard extends StatelessWidget {
  const NextSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'NEXT SESSION',
                  style: TextStyle(
                    color: Color(0xFFAEAEAE),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),
              Text(
                '14:30',
                style: TextStyle(
                  color: Color(0xFFF1FFD0),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Expanded(
                child: Text(
                  'POWER LIFT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'TODAY',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 118,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF075C6C),
                  child: Icon(
                    Icons.person,
                    color: Color(0xFFFFB79C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COACH',
                        style: TextStyle(
                          color: Color(0xFFB5B5B5),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'MARCUS\nSTEVENS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 102,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8FF00),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'DETAILS',
                      style: TextStyle(
                        color: Color(0xFF191919),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

