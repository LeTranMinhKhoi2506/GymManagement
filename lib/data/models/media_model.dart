import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  final String id;
  final String url;
  final String fileName;
  final String type; // 'image', 'video'
  final DateTime uploadedAt;
  final int size;

  MediaModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    required this.uploadedAt,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'type': type,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'size': size,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MediaModel(
      id: documentId,
      url: map['url'] ?? '',
      fileName: map['fileName'] ?? '',
      type: map['type'] ?? 'image',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      size: map['size'] ?? 0,
    );
  }
}
