import 'package:flutter/material.dart';
import '../data/models/content_model.dart';
import '../data/repository/content_repository.dart';

class ContentController extends ChangeNotifier {
  final ContentRepository _repository = ContentRepository();

  List<ContentModel> _contents = [];
  List<ContentModel> get contents => _contents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ContentController() {
    _init();
  }

  void _init() {
    _repository.getContentStream().listen((event) {
      _contents = event;
      notifyListeners();
    });
  }

  Future<void> addContent(ContentModel content) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addContent(content);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContent(ContentModel content) async {
    await _repository.updateContent(content);
  }

  Future<void> deleteContent(String id) async {
    await _repository.deleteContent(id);
  }

  Future<void> togglePublish(String id, bool isPublished) async {
    await _repository.togglePublish(id, isPublished);
  }
}
