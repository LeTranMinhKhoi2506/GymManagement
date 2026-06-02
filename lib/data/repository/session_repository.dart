import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'sessions';

  Stream<List<SessionModel>> getSessionsStream() {
    return _db.collection(_collection)
        .orderBy('loginAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteSession(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
  
  // Logic ghi nhận session thường được gọi từ AuthController khi login thành công
  Future<void> logSession(SessionModel session) async {
    await _db.collection(_collection).add({
      'userId': session.userId,
      'userName': session.userName,
      'device': session.device,
      'ipAddress': session.ipAddress,
      'loginAt': Timestamp.fromDate(session.loginAt),
    });
  }
}
