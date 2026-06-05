import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/route/routes.dart';

class HomeFeedHeader extends StatelessWidget {
  const HomeFeedHeader({
    super.key,
    this.onSearchTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  void _showQRDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final uid = user.uid;
        final displayId = uid.length > 8 ? uid.substring(0, 8).toUpperCase() : uid.toUpperCase();
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "MÃ QR THÀNH VIÊN",
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Đưa mã này cho lễ tân quét khi đến phòng tập để điểm danh",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: QrImageView(
                    data: uid,
                    version: QrVersions.auto,
                    size: 180.0,
                    gapless: false,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.displayName ?? "Thành viên Gym",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Mã số: $displayId",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("ĐÓNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchTap = onSearchTap ?? () => context.push(Routes.socialSearch);
    final notificationsTap =
        onNotificationsTap ?? () => context.push(Routes.socialNotifications);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Discover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showQRDialog(context),
                icon: const Icon(Icons.qr_code_2_rounded),
                color: Colors.white,
                iconSize: 29,
                tooltip: 'Mã QR điểm danh',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: searchTap,
                icon: const Icon(Icons.search_rounded),
                color: Colors.white,
                iconSize: 29,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: notificationsTap,
                icon: const Icon(Icons.notifications_none_rounded),
                color: Colors.white,
                iconSize: 29,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
