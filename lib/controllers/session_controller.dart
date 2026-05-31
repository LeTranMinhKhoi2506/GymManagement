import 'package:flutter/material.dart';
import '../data/models/session_model.dart';
import '../data/repository/session_repository.dart';

class SessionController extends ChangeNotifier {
  final SessionRepository _repository = SessionRepository();
  
  List<SessionModel> _sessions = [];
  List<SessionModel> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SessionController() {
    _init();
  }

  void _init() {
    _repository.getSessionsStream().listen((event) {
      _sessions = event;
      notifyListeners();
    });
  }

  Future<void> deleteSession(String id) async {
    await _repository.deleteSession(id);
  }

  Future<void> logSession(SessionModel session) async {
    await _repository.logSession(session);
  }
}
