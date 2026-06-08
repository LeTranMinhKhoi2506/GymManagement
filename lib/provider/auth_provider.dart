import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/database/database_setup_activity.dart';
import '../app/database/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestoreService;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  bool _loginPasswordHidden = true;
  bool _signUpPasswordHidden = true;
  bool _agreeTerms = false;
  bool _loading = false;

  bool get loginPasswordHidden => _loginPasswordHidden;
  bool get signUpPasswordHidden => _signUpPasswordHidden;
  bool get agreeTerms => _agreeTerms;
  bool get loading => _loading;
  bool get isAuthenticated => _authService.currentUser != null;

  void toggleLoginPassword() {
    _loginPasswordHidden = !_loginPasswordHidden;
    notifyListeners();
  }

  void toggleSignUpPassword() {
    _signUpPasswordHidden = !_signUpPasswordHidden;
    notifyListeners();
  }

  void setAgreeTerms(bool value) {
    _agreeTerms = value;
    notifyListeners();
  }

  Future<bool> signIn(BuildContext context) async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    final validationError = _validateLogin(email: email, password: password);
    if (validationError != null) {
      _showSnackBar(context, validationError);
      return false;
    }

    _setLoading(true);
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestoreService.ensureUserRoot(
        email: email,
        fullName: credential.user?.displayName,
        role: 'member',
      );

      if (!context.mounted) return false;
      return true;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return false;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return false;
      _showSnackBar(context, 'Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> continueSignUp(BuildContext context) async {
    final fullName = signUpNameController.text.trim();
    final email = signUpEmailController.text.trim();
    final phone = signUpPhoneController.text.trim();
    final password = signUpPasswordController.text;

    final validationError = _validateSignUp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );

    if (validationError != null) {
      _showSnackBar(context, validationError);
      return;
    }

    _setLoading(true);
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestoreService.ensureUserRoot(
        fullName: fullName,
        email: email,
        phone: phone,
        role: 'member',
      );

      loginEmailController.text = email;
      loginPasswordController.text = password;

      if (!context.mounted) return;
      _showSnackBar(context, 'Tạo tài khoản thành công. Bạn đã sẵn sàng đăng nhập.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Đăng ký thất bại. Vui lòng thử lại.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(BuildContext context) async {
    final email = loginEmailController.text.trim();
    if (!_isValidEmail(email)) {
      _showSnackBar(context, 'Vui lòng nhập email hợp lệ để lấy lại mật khẩu.');
      return;
    }

    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!context.mounted) return;
      _showSnackBar(context, 'Đã gửi email đặt lại mật khẩu.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Không thể gửi email lúc này.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _validateLogin({required String email, required String password}) {
    if (!_isValidEmail(email)) {
      return 'Email không hợp lệ.';
    }
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    return null;
  }

  String? _validateSignUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    if (fullName.length < 2) {
      return 'Họ tên tối thiểu 2 ký tự.';
    }
    if (!_isValidEmail(email)) {
      return 'Email không hợp lệ.';
    }
    if (!_isValidPhone(phone)) {
      return 'Số điện thoại không hợp lệ.';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (!_agreeTerms) {
      return 'Bạn cần đồng ý với Điều khoản & Chính sách bảo mật.';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không đúng định dạng.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai email hoặc mật khẩu.';
      case 'email-already-in-use':
        return 'Email này đã tồn tại.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra Internet.';
      default:
        return e.message ?? 'Đã có lỗi xảy ra.';
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPhoneController.dispose();
    signUpPasswordController.dispose();
    super.dispose();
  }

  Future<bool> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      loginEmailController.clear();
      loginPasswordController.clear();
      signUpNameController.clear();
      signUpEmailController.clear();
      signUpPhoneController.clear();
      signUpPasswordController.clear();
      _agreeTerms = false;
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
