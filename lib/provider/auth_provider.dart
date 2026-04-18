import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/database/DatabaseSetupActivity.dart';
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

  Future<void> signIn(BuildContext context) async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    final validationError = _validateLogin(email: email, password: password);
    if (validationError != null) {
      _showSnackBar(context, validationError);
      return;
    }

    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!context.mounted) return;
      _showSnackBar(context, 'Dang nhap thanh cong.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Dang nhap that bai. Vui long thu lai.');
    } finally {
      _setLoading(false);
    }
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
      _showSnackBar(context, 'Tao tai khoan thanh cong. Ban da san sang dang nhap.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Dang ky that bai. Vui long thu lai.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(BuildContext context) async {
    final email = loginEmailController.text.trim();
    if (!_isValidEmail(email)) {
      _showSnackBar(context, 'Vui long nhap email hop le de lay lai mat khau.');
      return;
    }

    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!context.mounted) return;
      _showSnackBar(context, 'Da gui email dat lai mat khau.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, _mapFirebaseAuthError(e));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Khong the gui email luc nay.');
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
      return 'Email khong hop le.';
    }
    if (password.isEmpty) {
      return 'Vui long nhap mat khau.';
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
      return 'Ho ten toi thieu 2 ky tu.';
    }
    if (!_isValidEmail(email)) {
      return 'Email khong hop le.';
    }
    if (!_isValidPhone(phone)) {
      return 'So dien thoai khong hop le.';
    }
    if (password.length < 6) {
      return 'Mat khau phai co it nhat 6 ky tu.';
    }
    if (!_agreeTerms) {
      return 'Ban can dong y Terms & Privacy Policy.';
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
        return 'Email khong dung dinh dang.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai email hoac mat khau.';
      case 'email-already-in-use':
        return 'Email nay da ton tai.';
      case 'weak-password':
        return 'Mat khau qua yeu.';
      case 'too-many-requests':
        return 'Ban thao tac qua nhanh. Vui long thu lai sau.';
      case 'network-request-failed':
        return 'Loi ket noi mang. Vui long kiem tra Internet.';
      default:
        return e.message ?? 'Da co loi xay ra.';
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
}
