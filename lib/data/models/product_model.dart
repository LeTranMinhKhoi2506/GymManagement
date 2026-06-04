import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category; // 'Supplements', 'Equipment', 'Apparel', 'Drinks'
  final double price;
  final int stock;
  final String? imageUrl;
  final String description;
  final DateTime? lastUpdated;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description = '',
    this.lastUpdated,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'],
      description: map['description'] ?? '',
      lastUpdated: map['lastUpdated'] != null ? (map['lastUpdated'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
