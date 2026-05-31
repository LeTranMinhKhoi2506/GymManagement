import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'categories';

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection(_collection).add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection(_collection).doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
