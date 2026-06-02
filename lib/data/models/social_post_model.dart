import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout_exercise_model.dart';

class SocialPostModel {
  SocialPostModel({
    required this.id,
    required this.authorId,
    required this.author,
    required this.authorAvatarUrl,
    required this.caption,
    required this.mediaItems,
    required this.timeLabel,
    required this.likes,
    required this.comments,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
    this.isLiked = false,
  });

  final String id;
  final String authorId;
  final String author;
  final String? authorAvatarUrl;
  final String caption;
  final List<SocialMediaModel> mediaItems;
  final String timeLabel;
  final int likes;
  final int comments;
  final List<WorkoutExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLiked;

  String get imagePath => mediaItems.isNotEmpty ? mediaItems.first.path : '';

  SocialPostModel copyWith({
    String? id,
    String? authorId,
    String? author,
    String? authorAvatarUrl,
    String? caption,
    List<SocialMediaModel>? mediaItems,
    String? timeLabel,
    int? likes,
    int? comments,
    List<WorkoutExerciseModel>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      caption: caption ?? this.caption,
      mediaItems: mediaItems ?? this.mediaItems,
      timeLabel: timeLabel ?? this.timeLabel,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'author': author,
      'authorAvatarUrl': authorAvatarUrl,
      'caption': caption,
      'mediaItems': mediaItems.map((item) => item.toMap()).toList(),
      'timeLabel': timeLabel,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'exercises': exercises.map((item) => item.toMap()).toList(),
    };
  }

  factory SocialPostModel.fromMap(Map<String, dynamic> map) {
    final rawExercises = (map['exercises'] as List?) ?? const [];
    final rawMediaItems = (map['mediaItems'] as List?) ?? const [];
    final fallbackImagePath = map['imagePath'] as String?;
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    final mediaItems = rawMediaItems.isNotEmpty
        ? rawMediaItems
            .whereType<Map>()
            .map(
              (item) => SocialMediaModel.fromMap(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList()
        : (fallbackImagePath != null && fallbackImagePath.isNotEmpty
            ? [
                SocialMediaModel(
                  path: fallbackImagePath,
                  type: SocialMediaType.image,
                ),
              ]
            : <SocialMediaModel>[]);

    return SocialPostModel(
      id: (map['id'] as String?) ?? '',
      authorId: (map['authorId'] as String?) ?? '',
      author: (map['author'] as String?) ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] as String?,
      caption: (map['caption'] as String?) ?? '',
      mediaItems: mediaItems,
      timeLabel: (map['timeLabel'] as String?) ?? '',
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      comments: (map['comments'] as num?)?.toInt() ?? 0,
      isLiked: (map['isLiked'] as bool?) ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
      exercises: rawExercises
          .whereType<Map>()
          .map(
            (item) => WorkoutExerciseModel.fromMap(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
    );
  }
}
