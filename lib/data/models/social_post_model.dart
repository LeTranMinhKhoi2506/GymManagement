import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout_exercise_model.dart';

class SocialPostModel {
  SocialPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.caption,
    required this.mediaItems,
    required this.timeLabel,
    required this.likeCount,
    required this.commentCount,
    required this.exercises,
    required this.createdAt,
    this.authorAvatarUrl,
    this.updatedAt,
    this.isLiked = false,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String caption;
  final List<SocialMediaModel> mediaItems;
  final String timeLabel;
  final int likeCount;
  final int commentCount;
  final List<WorkoutExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLiked;

  String get imagePath => mediaItems.isNotEmpty ? mediaItems.first.path : '';

  SocialPostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? caption,
    List<SocialMediaModel>? mediaItems,
    String? timeLabel,
    int? likeCount,
    int? commentCount,
    List<WorkoutExerciseModel>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      caption: caption ?? this.caption,
      mediaItems: mediaItems ?? this.mediaItems,
      timeLabel: timeLabel ?? this.timeLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
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
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'caption': caption,
      'mediaItems': mediaItems.map((item) => item.toMap()).toList(),
      'timeLabel': timeLabel,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'exercises': exercises.map((item) => item.toMap()).toList(),
    };
  }

  factory SocialPostModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    final rawMediaItems = (map['mediaItems'] as List?) ?? const [];
    final fallbackImagePath = map['imagePath'] as String?;
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

    final rawExercises = (map['exercises'] as List?) ?? const [];

    return SocialPostModel(
      id: (map['id'] as String?) ?? '',
      authorId: (map['authorId'] as String?) ?? '',
      authorName:
          (map['authorName'] as String?) ??
          (map['author'] as String?) ??
          'Member',
      authorAvatarUrl: map['authorAvatarUrl'] as String?,
      caption: (map['caption'] as String?) ?? '',
      mediaItems: mediaItems,
      timeLabel: (map['timeLabel'] as String?) ?? '',
      likeCount:
          (map['likeCount'] as num?)?.toInt() ??
          (map['likes'] as num?)?.toInt() ??
          0,
      commentCount:
          (map['commentCount'] as num?)?.toInt() ??
          (map['comments'] as num?)?.toInt() ??
          0,
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
