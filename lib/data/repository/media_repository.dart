import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';

class MediaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'media_library';

  Stream<List<MediaModel>> getMediaStream() {
    return _db.collection(_collection)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MediaModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addMedia(MediaModel media) async {
    await _db.collection(_collection).add(media.toMap());
  }

  Future<void> deleteMedia(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
