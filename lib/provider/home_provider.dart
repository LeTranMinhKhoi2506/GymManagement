import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/models/comment_model.dart';
import '../data/models/social_post_model.dart';
import '../data/models/workout_exercise_model.dart';
import '../data/repository/social_post_repository.dart';

enum HomeFeedMode { discover, following }

class DraftExerciseInput {
  DraftExerciseInput({this.name = '', this.sets = '', this.reps = ''});

  final String name;
  final String sets;
  final String reps;

  DraftExerciseInput copyWith({String? name, String? sets, String? reps}) {
    return DraftExerciseInput(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }
}

class HomeProvider extends ChangeNotifier {
  HomeProvider({SocialPostRepository? repository})
    : _repository = repository ?? SocialPostRepository(),
      _draftExercises = [DraftExerciseInput()] {
    _postsSubscription = _repository.watchPosts().listen(
      (items) {
        _posts = _markLiked(items);
        _loading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  final SocialPostRepository _repository;
  late final StreamSubscription<List<SocialPostModel>> _postsSubscription;

  int _selectedIndex = 0;
  HomeFeedMode _feedMode = HomeFeedMode.discover;
  String _draftCaption = '';
  final List<SocialMediaModel> _draftMediaItems = [];
  bool _isPosting = false;
  bool _loading = true;
  String? _errorMessage;
  List<SocialPostModel> _posts = [];
  List<DraftExerciseInput> _draftExercises;
  final Set<String> _likedPostIds = <String>{};

  int get selectedIndex => _selectedIndex;
  HomeFeedMode get feedMode => _feedMode;
  String get draftCaption => _draftCaption;
  List<SocialMediaModel> get draftMediaItems =>
      List.unmodifiable(_draftMediaItems);
  bool get isPosting => _isPosting;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<SocialPostModel> get posts => List.unmodifiable(_posts);
  List<DraftExerciseInput> get draftExercises =>
      List.unmodifiable(_draftExercises);

  bool get canPost {
    if (_isPosting) return false;
    final hasCaption = _draftCaption.trim().isNotEmpty;
    final hasMedia = _draftMediaItems.isNotEmpty;
    return hasCaption || hasMedia;
  }

  void changeTab(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void changeFeedMode(HomeFeedMode mode) {
    if (_feedMode == mode) return;
    _feedMode = mode;
    notifyListeners();
  }

  void updateDraftCaption(String value) {
    _draftCaption = value;
    notifyListeners();
  }

  void addExerciseDraft() {
    _draftExercises = [..._draftExercises, DraftExerciseInput()];
    notifyListeners();
  }

  void removeExerciseDraft(int index) {
    if (_draftExercises.length == 1 ||
        index < 0 ||
        index >= _draftExercises.length) {
      return;
    }
    final next = [..._draftExercises]..removeAt(index);
    _draftExercises = next;
    notifyListeners();
  }

  void updateExerciseName(int index, String value) {
    if (index < 0 || index >= _draftExercises.length) return;
    final next = [..._draftExercises];
    next[index] = next[index].copyWith(name: value);
    _draftExercises = next;
    notifyListeners();
  }

  void updateExerciseSets(int index, String value) {
    if (index < 0 || index >= _draftExercises.length) return;
    final next = [..._draftExercises];
    next[index] = next[index].copyWith(sets: value);
    _draftExercises = next;
    notifyListeners();
  }

  void updateExerciseReps(int index, String value) {
    if (index < 0 || index >= _draftExercises.length) return;
    final next = [..._draftExercises];
    next[index] = next[index].copyWith(reps: value);
    _draftExercises = next;
    notifyListeners();
  }

  Future<String?> pickWorkoutPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result == null) return null;

      for (final file in result.files) {
        if (file.path == null) continue;
        _draftMediaItems.add(
          SocialMediaModel(path: file.path!, type: SocialMediaType.image),
        );
      }
      notifyListeners();
      return null;
    } catch (_) {
      return 'Could not pick photos. Please try again.';
    }
  }

  Future<String?> pickWorkoutVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );
      if (result == null) return null;

      for (final file in result.files) {
        if (file.path == null) continue;
        _draftMediaItems.add(
          SocialMediaModel(path: file.path!, type: SocialMediaType.video),
        );
      }
      notifyListeners();
      return null;
    } catch (_) {
      return 'Could not pick videos. Please try again.';
    }
  }

  void removeDraftMediaAt(int index) {
    if (index < 0 || index >= _draftMediaItems.length) return;
    _draftMediaItems.removeAt(index);
    notifyListeners();
  }

  void resetDraft() {
    _draftCaption = '';
    _draftMediaItems.clear();
    _draftExercises = [DraftExerciseInput()];
    notifyListeners();
  }

  Stream<List<CommentModel>> watchComments(String postId) {
    return _repository.watchComments(postId);
  }

  Future<String?> addComment({
    required String postId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return 'Binh luan khong duoc de trong.';
    }

    try {
      await _repository.addComment(postId: postId, content: trimmed);
      return null;
    } catch (_) {
      return 'Dang binh luan that bai. Vui long thu lai.';
    }
  }

  Future<String?> createPost() async {
    final hasCaption = _draftCaption.trim().isNotEmpty;
    final hasMedia = _draftMediaItems.isNotEmpty;
    if (!hasCaption && !hasMedia) {
      return 'Please add caption or choose at least one photo/video.';
    }

    final exercises = _toExerciseModels();

    _isPosting = true;
    notifyListeners();

    try {
      await _repository.createPost(
        caption: _draftCaption.trim(),
        mediaItems: List<SocialMediaModel>.from(_draftMediaItems),
        exercises: exercises,
      );
      resetDraft();
      return null;
    } catch (_) {
      return 'Post failed. Please try again.';
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final liked = _likedPostIds.contains(postId);
    await _repository.toggleLike(postId);
    if (liked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    _posts = _markLiked(_posts);
    notifyListeners();
  }

  bool isLocalFile(String path) => File(path).existsSync();

  List<WorkoutExerciseModel> _toExerciseModels() {
    return _draftExercises
        .map((item) {
          final name = item.name.trim();
          final sets = int.tryParse(item.sets.trim());
          final reps = int.tryParse(item.reps.trim());
          if (name.isEmpty ||
              sets == null ||
              reps == null ||
              sets <= 0 ||
              reps <= 0) {
            return null;
          }
          return WorkoutExerciseModel(name: name, sets: sets, reps: reps);
        })
        .whereType<WorkoutExerciseModel>()
        .toList();
  }

  List<SocialPostModel> _markLiked(List<SocialPostModel> items) {
    return items
        .map((post) => post.copyWith(isLiked: _likedPostIds.contains(post.id)))
        .toList();
  }

  @override
  void dispose() {
    _postsSubscription.cancel();
    super.dispose();
  }
}
