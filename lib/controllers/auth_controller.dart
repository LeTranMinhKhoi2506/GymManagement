import 'package:firebase_auth/firebase_auth.dart';
import '../data/repository/auth_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/session_model.dart';
import '../data/repository/session_repository.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Đăng nhập
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result = await _repository.signIn(email, password);
      User? user = result.user;

      if (user != null) {
        _currentUser = await _repository.getUserData(user.uid);
        
        if (_currentUser == null) {
          _currentUser = UserModel(
            uid: user.uid,
            email: user.email ?? email,
            fullName: user.displayName ?? "User từ Firebase",
            role: kIsWeb ? 'admin' : 'user',
          );
          await _repository.saveUserData(_currentUser!);
        }
        
        // Ghi lại Session đăng nhập (Session Management)
        await _sessionRepository.logSession(SessionModel(
          id: '',
          userId: _currentUser!.uid,
          userName: _currentUser!.fullName,
          device: kIsWeb ? "Web Browser" : "Mobile App",
          ipAddress: "192.168.1.1", // Trong thực tế sẽ lấy IP thật
          loginAt: DateTime.now(),
        ));
        
        _setLoading(false);
        notifyListeners();
        return {"status": "success", "user": _currentUser};
      }
      _setLoading(false);
      return {"status": "error", "message": "Đăng nhập thất bại."};
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return {"status": "error", "message": e.message};
    } catch (e) {
      _setLoading(false);
      return {"status": "error", "message": e.toString()};
    }
  }

  // Đăng ký
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _setLoading(true);
    try {
      User? user = await _repository.signUp(email, password);
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          role: role,
        );
        await _repository.saveUserData(newUser);
        _setLoading(false);
        return "success";
      }
      _setLoading(false);
      return "Không thể tạo tài khoản.";
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  // Quên mật khẩu
  Future<String?> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _repository.sendPasswordResetEmail(email);
      _setLoading(false);
      return "success";
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
