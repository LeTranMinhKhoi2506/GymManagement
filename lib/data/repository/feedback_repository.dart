import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'feedbacks';

  Stream<List<FeedbackModel>> getFeedbacksStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateFeedbackStatus(String id, String status, {String? adminReply}) async {
    final Map<String, dynamic> updateData = {
      'status': status,
    };
    if (adminReply != null) {
      updateData['adminReply'] = adminReply;
      updateData['repliedAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection(_collection).doc(id).update(updateData);
  }

  Future<void> deleteFeedback(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
