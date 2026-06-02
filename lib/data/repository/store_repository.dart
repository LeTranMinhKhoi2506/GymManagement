import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class StoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'products';

  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection(_collection).add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection(_collection).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
