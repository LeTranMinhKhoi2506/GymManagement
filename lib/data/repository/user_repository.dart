import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Lấy danh sách tài khoản dưới dạng Stream
  Stream<List<UserModel>> getUsersStream() {
    return _db.collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Kiểm tra email trùng lặp
  Future<bool> isEmailExists(String email, {String? excludeUid}) async {
    final query = _db.collection(_collection).where('email', isEqualTo: email.trim());
    final snapshot = await query.get();
    
    if (excludeUid != null) {
      return snapshot.docs.any((doc) => doc.id != excludeUid);
    }
    return snapshot.docs.isNotEmpty;
  }

  // Thêm tài khoản mới
  Future<void> addUser(UserModel user) async {
    await _db.collection(_collection).doc(user.uid).set(user.toMap());
  }

  // Cập nhật tài khoản
  Future<void> updateUser(UserModel user) async {
    await _db.collection(_collection).doc(user.uid).update(user.toMap());
  }

  // Xóa tài khoản
  Future<void> deleteUser(String uid) async {
    await _db.collection(_collection).doc(uid).delete();
  }
}
