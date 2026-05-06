import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class CustomerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'members';

  Stream<List<MemberModel>> getMembersStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MemberModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ActivityLog>> getActivityLogsStream(String memberId) {
    return _db.collection(_collection).doc(memberId).collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ActivityLog.fromMap(doc.data())).toList();
    });
  }

  Future<void> addMember(MemberModel member) async {
    await _db.collection(_collection).add(member.toMap());
  }

  Future<void> updateMember(MemberModel member) async {
    await _db.collection(_collection).doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
