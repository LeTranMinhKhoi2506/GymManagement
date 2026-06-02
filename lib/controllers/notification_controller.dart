import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/repository/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotificationController() {
    _init();
  }

  void _init() {
    _repository.getNotificationsStream().listen((event) {
      _notifications = event;
      notifyListeners();
    });
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required String type,
    String? targetUserId,
    String? sentBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    final notification = NotificationModel(
      id: '',
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      targetUserId: targetUserId,
      sentBy: sentBy,
    );

    try {
      await _repository.sendNotification(notification);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }
}
