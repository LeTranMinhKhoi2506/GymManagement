import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class StaffRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<UserModel>> getStaffStream() {
    return _db.collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  Future<bool> isEmailExists(String email, {String? excludeUid}) async {
    final query = _db.collection('users').where('email', isEqualTo: email);
    final snapshot = await query.get();
    
    if (excludeUid != null) {
      return snapshot.docs.any((doc) => doc.id != excludeUid);
    }
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addStaff(UserModel staff) async {
    await _db.collection('users').doc(staff.uid).set(staff.toMap());
  }

  Future<void> updateStaff(UserModel staff) async {
    await _db.collection('users').doc(staff.uid).update(staff.toMap());
  }

  Future<void> deleteStaff(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
