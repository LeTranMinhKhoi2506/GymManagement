import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/comment_model.dart';
import '../models/social_post_model.dart';
import '../models/user_model.dart';
import '../models/workout_exercise_model.dart';

class SocialPostRepository {
  SocialPostRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Stream<List<SocialPostModel>> watchPosts() {
    final currentUserId = _auth.currentUser?.uid;
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = snapshot.docs.map(_fromDoc).toList();
      if (currentUserId == null) {
        return posts;
      }

      final likedDocs = await Future.wait(
        snapshot.docs.map(
          (doc) => doc.reference.collection('likes').doc(currentUserId).get(),
        ),
      );

      return [
        for (var index = 0; index < posts.length; index++)
          posts[index].copyWith(isLiked: likedDocs[index].exists),
      ];
    });
  }

  Stream<List<CommentModel>> watchComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _commentFromDoc(doc))
          .where((comment) => !comment.isDeleted)
          .toList();
    });
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Vui long dang nhap de binh luan.');
    }

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw StateError('Noi dung binh luan khong duoc de trong.');
    }

    final profile = await _loadAuthorProfile(user);
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();
    final comment = CommentModel(
      id: commentRef.id,
      authorId: user.uid,
      authorName: profile.fullName,
      authorAvatarUrl: profile.avatarUrl,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw StateError('Bai viet khong ton tai.');
      }
      transaction.set(commentRef, comment.toMap());
      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

    final profile = await _loadAuthorProfile(user);
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
      authorName: profile.fullName,
      authorAvatarUrl: profile.avatarUrl,
      caption: caption,
      mediaItems: uploadedMedia,
      timeLabel: _formatRelativeTime(createdAt),
      likeCount: 0,
      commentCount: 0,
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
      if (!postSnapshot.exists) return;

      final likeSnapshot = await transaction.get(likeRef);
      if (likeSnapshot.exists) {
        transaction.delete(likeRef);
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    final updatedDoc = await postRef.get();
    if (!updatedDoc.exists) return null;
    return _fromDoc(updatedDoc);
  }

  Future<_AuthorProfile> _loadAuthorProfile(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    final fullName = (data?['fullName'] as String?)?.trim();
    final name = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : (user.email ?? 'Member').split('@').first);

    return _AuthorProfile(
      fullName: name,
      avatarUrl: (data?['avatarUrl'] as String?) ?? user.photoURL,
    );
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

  SocialPostModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SocialPostModel.fromMap({...data, 'id': doc.id});
  }

  CommentModel _commentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CommentModel.fromMap({
      ...(doc.data() ?? <String, dynamic>{}),
      'id': doc.id,
    });
  }

  String _guessImageMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Stream<List<SocialPostModel>> watchPostsByUserId(String userId) {
    final currentUserId = _auth.currentUser?.uid;
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = snapshot.docs.map(_fromDoc).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (currentUserId == null) {
        return posts;
      }

      final likedDocs = await Future.wait(
        snapshot.docs.map(
          (doc) => doc.reference.collection('likes').doc(currentUserId).get(),
        ),
      );

      return [
        for (var index = 0; index < posts.length; index++)
          posts[index].copyWith(isLiked: likedDocs[index].exists),
      ];
    });
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }
}

class _AuthorProfile {
  const _AuthorProfile({required this.fullName, required this.avatarUrl});

  final String fullName;
  final String? avatarUrl;
}
