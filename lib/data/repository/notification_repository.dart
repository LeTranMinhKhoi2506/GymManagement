import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Stream<List<NotificationModel>> getNotificationsStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendNotification(NotificationModel notification) async {
    await _db.collection(_collection).add(notification.toMap());
  }

  Future<void> deleteNotification(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> markAsRead(String id) async {
    await _db.collection(_collection).doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final unreadDocs = await _db
        .collection(_collection)
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _db.batch();
    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
