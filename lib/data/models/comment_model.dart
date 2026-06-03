import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.authorAvatarUrl,
    this.isDeleted = false,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;

  CommentModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return CommentModel(
      id: (map['id'] as String?) ?? '',
      authorId: (map['authorId'] as String?) ?? '',
      authorName: (map['authorName'] as String?) ?? 'Member',
      authorAvatarUrl: map['authorAvatarUrl'] as String?,
      content: (map['content'] as String?) ?? '',
      createdAt: parseDate(map['createdAt']),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
    );
  }
}
