import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String category;
  final String author;
  final DateTime createdAt;
  final bool isPublished;

  ContentModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.category,
    required this.author,
    required this.createdAt,
    this.isPublished = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'category': category,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ContentModel(
      id: documentId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imageUrl: map['imageUrl'],
      category: map['category'] ?? 'Chung',
      author: map['author'] ?? 'Admin',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPublished: map['isPublished'] ?? true,
    );
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    String? category,
    String? author,
    DateTime? createdAt,
    bool? isPublished,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
