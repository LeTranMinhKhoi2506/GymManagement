import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../app/route/routes.dart';
import '../../../data/models/notification_model.dart';
import 'admin_search_dialog.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chào mừng trở lại, ${user?.fullName ?? 'Admin'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const Text("Tổng quan hệ thống",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          // Search Button (Opens command palette search dialog)
          _headerAction(
            Icons.search,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const AdminSearchDialog(),
              );
            },
          ),
          const SizedBox(width: 16),
          // Notifications Dropdown with real-time Badge
          MenuAnchor(
            style: MenuStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevation: WidgetStateProperty.all(12),
            ),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              final notificationController = Provider.of<NotificationController>(context);
              final unreadCount = notificationController.notifications.where((n) => !n.isRead).length;

              return Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                backgroundColor: const Color(0xFFFF6B35),
                child: _headerAction(
                  Icons.notifications_none,
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                ),
              );
            },
            menuChildren: [
              _buildNotificationDropdown(context),
            ],
          ),
          const SizedBox(width: 24),
          const VerticalDivider(indent: 20, endIndent: 20),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(user?.fullName ?? "Quản trị viên",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(user?.role.toUpperCase() ?? "ADMIN",
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0A192F),
            child: Text(
              (user?.fullName ?? "A").substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildNotificationDropdown(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context);
    final notifications = notificationController.notifications;

    return SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông báo mới nhận',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A192F)),
                ),
                if (notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: () {
                      notificationController.markAllAsRead();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Đọc tất cả',
                      style: TextStyle(color: Color(0xFFFF6B35), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List of notifications
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off_outlined, color: Colors.grey, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có thông báo nào.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...notifications.take(5).map((notif) {
                  final isLast = notif == notifications.take(5).last;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNotificationItem(context, notif, notificationController),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          const Divider(height: 1),
          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: InkWell(
              onTap: () {
                context.go(Routes.notificationManagement);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem tất cả thông báo',
                    style: TextStyle(fontSize: 13, color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFFFF6B35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif, NotificationController controller) {
    Color typeColor;
    IconData typeIcon;
    switch (notif.type) {
      case 'promotion':
        typeColor = Colors.orange;
        typeIcon = Icons.campaign_outlined;
        break;
      case 'alert':
        typeColor = Colors.red;
        typeIcon = Icons.warning_amber_outlined;
        break;
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.notifications_none_outlined;
    }

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          controller.markAsRead(notif.id);
        }
        _showNotificationDetail(context, notif, controller);
      },
      child: Container(
        color: notif.isRead ? Colors.transparent : const Color(0xFFFF6B35).withValues(alpha: 0.03),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: typeColor.withValues(alpha: 0.1),
              child: Icon(typeIcon, color: typeColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            color: const Color(0xFF0A192F),
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                controller.deleteNotification(notif.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  void _showNotificationDetail(BuildContext context, NotificationModel notif, NotificationController controller) {
    showDialog(
      context: context,
      builder: (context) {
        Color typeColor;
        IconData typeIcon;
        String typeLabel;
        switch (notif.type) {
          case 'promotion':
            typeColor = Colors.orange;
            typeIcon = Icons.campaign;
            typeLabel = 'Khuyến mãi';
            break;
          case 'alert':
            typeColor = Colors.red;
            typeIcon = Icons.warning_amber;
            typeLabel = 'Cảnh báo';
            break;
          default:
            typeColor = Colors.blue;
            typeIcon = Icons.notifications_none;
            typeLabel = 'Chung';
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: typeColor.withValues(alpha: 0.1),
                child: Icon(typeIcon, color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                    ),
                    Text(
                      typeLabel,
                      style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif.message,
                style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF2D3748)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Người gửi: ${notif.sentBy ?? 'Hệ thống'}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteNotification(notif.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xóa thông báo'),
            ),
          ],
        );
      },
    );
  }
}

