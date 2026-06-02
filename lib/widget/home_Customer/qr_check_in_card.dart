import 'package:flutter/material.dart';

class QrCheckInCard extends StatelessWidget {
  const QrCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: const [
          _QrIconBox(),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY QR CHECK-IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'READY FOR ACCESS',
                  style: TextStyle(
                    color: Color(0xFFB8B8B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Color(0xFFF1FFD0),
            size: 46,
          ),
        ],
      ),
    );
  }
}

class _QrIconBox extends StatelessWidget {
  const _QrIconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF5B5B5B)),
      ),
      child: const Icon(
        Icons.qr_code_2,
        color: Color(0xFFF1FFD0),
        size: 36,
      ),
    );
  }
}

