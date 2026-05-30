import 'package:firebase_auth/firebase_auth.dart';
import '../data/repository/auth_repository.dart';
import '../data/models/user_model.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

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
        
        try {
          await _repository.sendEmailVerification(user);
        } catch (e) {
          dev.log("AuthController - Gửi email xác thực bị lỗi: $e");
        }

        _setLoading(false);
        return "success";
      }
      _setLoading(false);
      return "Không thể tạo tài khoản.";
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result = await _repository.signIn(email, password);
      User? user = result.user;

      if (user != null) {
        _currentUser = await _repository.getUserData(user.uid);
        
        // CẢI TIẾN: Nếu không tìm thấy data trong Firestore (Acc tạo từ Console)
        if (_currentUser == null) {
          dev.log("AuthController - Không thấy data, tự động tạo mới cho UID: ${user.uid}");
          _currentUser = UserModel(
            uid: user.uid,
            email: user.email ?? email,
            fullName: user.displayName ?? "User từ Firebase",
            role: kIsWeb ? 'admin' : 'user', // Tự động gán role theo platform
          );
          await _repository.saveUserData(_currentUser!);
        }
        
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

  // Gửi lại email xác thực
  Future<void> resendVerification() async {
    final user = _repository.currentUser;
    if (user != null) {
      await _repository.sendEmailVerification(user);
    }
  }

  // Quên mật khẩu
  Future<String?> resetPassword(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng xuất
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
