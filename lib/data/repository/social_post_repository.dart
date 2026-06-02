import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/social_post_model.dart';
import '../models/workout_exercise_model.dart';

class SocialPostRepository {
  SocialPostRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Stream<List<SocialPostModel>> watchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final currentUserId = _auth.currentUser?.uid;
          return snapshot.docs
              .map((doc) => _fromDoc(doc, currentUserId: currentUserId))
              .toList();
        });
  }

  Future<SocialPostModel> createPost({
    required String caption,
    required List<SocialMediaModel> mediaItems,
    required List<WorkoutExerciseModel> exercises,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Vui long dang nhap de dang bai.');
    }

    final author = await _loadAuthorProfile(
      user.uid,
      fallbackEmail: user.email,
    );
    final postRef = _firestore.collection('posts').doc();
    final createdAt = DateTime.now();
    final uploadedMedia = await _uploadMediaItems(
      postId: postRef.id,
      userId: user.uid,
      mediaItems: mediaItems,
    );

    final post = SocialPostModel(
      id: postRef.id,
      authorId: user.uid,
      author: author.name,
      authorAvatarUrl: author.avatarUrl,
      caption: caption,
      mediaItems: uploadedMedia,
      timeLabel: 'Just now',
      likes: 0,
      comments: 0,
      exercises: exercises,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final payload = post.toMap();
    payload['isDeleted'] = false;
    await postRef.set(payload);
    return post;
  }

  Future<SocialPostModel?> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Vui long dang nhap de thich bai viet.');
    }

    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        return;
      }

      final likeSnapshot = await transaction.get(likeRef);
      if (likeSnapshot.exists) {
        transaction.delete(likeRef);
        transaction.update(postRef, {
          'likes': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {
          'likes': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    final updatedDoc = await postRef.get();
    if (!updatedDoc.exists) {
      return null;
    }
    return _fromDoc(updatedDoc, currentUserId: user.uid);
  }

  Future<_AuthorProfile> _loadAuthorProfile(
    String userId, {
    String? fallbackEmail,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final data = userDoc.data();
    final fullName = data?['fullName'] as String?;
    final avatarUrl = data?['avatarUrl'] as String?;
    final displayName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : _fallbackDisplayName(fallbackEmail);

    return _AuthorProfile(name: displayName, avatarUrl: avatarUrl);
  }

  String _fallbackDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'Member';
    final prefix = email.split('@').first;
    return prefix.isEmpty ? 'Member' : prefix;
  }

  Future<List<SocialMediaModel>> _uploadMediaItems({
    required String postId,
    required String userId,
    required List<SocialMediaModel> mediaItems,
  }) async {
    final result = <SocialMediaModel>[];

    for (var index = 0; index < mediaItems.length; index++) {
      final item = mediaItems[index];
      final file = File(item.path);

      if (!file.existsSync()) {
        result.add(item);
        continue;
      }

      final fileName = p.basename(item.path);
      final storageRef = _storage
          .ref()
          .child('social_posts')
          .child(userId)
          .child(postId)
          .child('$index-$fileName');

      final metadata = SettableMetadata(
        contentType: item.type == SocialMediaType.video
            ? 'video/mp4'
            : _guessImageMimeType(fileName),
      );

      await storageRef.putFile(file, metadata);
      final downloadUrl = await storageRef.getDownloadURL();
      result.add(item.copyWith(path: downloadUrl));
    }

    return result;
  }

  String _guessImageMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  SocialPostModel _fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? currentUserId,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    final post = SocialPostModel.fromMap({...data, 'id': doc.id});

    return post.copyWith(
      isLiked: currentUserId == null
          ? post.isLiked
          : false, // toggled locally after user action
    );
  }
}

class _AuthorProfile {
  const _AuthorProfile({required this.name, required this.avatarUrl});

  final String name;
  final String? avatarUrl;
}
