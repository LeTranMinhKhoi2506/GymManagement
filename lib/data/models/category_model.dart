class CategoryModel {
  final String id;
  final String name;
  final String type; // 'Content', 'Equipment', 'Product'
  final int itemCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.itemCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'itemCount': itemCount,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'Content',
      itemCount: map['itemCount'] ?? 0,
    );
  }
}
