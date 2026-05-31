import 'package:flutter/material.dart';
import '../data/models/feedback_model.dart';
import '../data/repository/feedback_repository.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();
  
  List<FeedbackModel> _feedbacks = [];
  List<FeedbackModel> get feedbacks => _feedbacks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FeedbackController() {
    _init();
  }

  void _init() {
    _repository.getFeedbacksStream().listen((event) {
      _feedbacks = event;
      notifyListeners();
    });
  }

  Future<void> replyFeedback(String id, String reply) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateFeedbackStatus(id, 'replied', adminReply: reply);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveFeedback(String id) async {
    await _repository.updateFeedbackStatus(id, 'resolved');
  }

  Future<void> deleteFeedback(String id) async {
    await _repository.deleteFeedback(id);
  }
}
