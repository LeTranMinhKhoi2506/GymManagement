import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/social-notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 18, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: Color(0xFF8A8D93),
            ),
            const SizedBox(height: 18),
            const Text(
              'No recent notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "We'll notify you when you have new activity",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8A8D93),
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
