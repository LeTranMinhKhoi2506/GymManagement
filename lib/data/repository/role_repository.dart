import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_model.dart';

class RoleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'roles';

  Stream<List<RoleModel>> getRolesStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RoleModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addRole(RoleModel role) async {
    await _db.collection(_collection).add(role.toMap());
  }

  Future<void> updateRole(RoleModel role) async {
    await _db.collection(_collection).doc(role.id).update(role.toMap());
  }

  Future<void> deleteRole(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
