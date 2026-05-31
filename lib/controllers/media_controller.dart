import 'package:flutter/material.dart';
import '../data/models/media_model.dart';
import '../data/repository/media_repository.dart';

class MediaController extends ChangeNotifier {
  final MediaRepository _repository = MediaRepository();
  
  List<MediaModel> _mediaList = [];
  List<MediaModel> get mediaList => _mediaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MediaController() {
    _init();
  }

  void _init() {
    _repository.getMediaStream().listen((event) {
      _mediaList = event;
      notifyListeners();
    });
  }

  Future<void> uploadMedia({
    required String url,
    required String fileName,
    required String type,
    required int size,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final media = MediaModel(
        id: '',
        url: url,
        fileName: fileName,
        type: type,
        uploadedAt: DateTime.now(),
        size: size,
      );
      await _repository.addMedia(media);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedia(String id) async {
    await _repository.deleteMedia(id);
  }
}
