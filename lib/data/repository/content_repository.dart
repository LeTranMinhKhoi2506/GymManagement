import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class ContentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'contents';

  Stream<List<ContentModel>> getContentStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addContent(ContentModel content) async {
    await _db.collection(_collection).add(content.toMap());
  }

  Future<void> updateContent(ContentModel content) async {
    await _db.collection(_collection).doc(content.id).update(content.toMap());
  }

  Future<void> deleteContent(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> togglePublish(String id, bool isPublished) async {
    await _db.collection(_collection).doc(id).update({'isPublished': isPublished});
  }
}
