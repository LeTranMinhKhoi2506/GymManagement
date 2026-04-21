import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:developer' as dev;

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đăng ký
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      dev.log("AuthRepository - signUp error: $e");
      rethrow;
    }
  }

  // Đăng nhập
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Gửi email xác thực - Cải tiến: Nhận đối tượng User trực tiếp
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
      dev.log("AuthRepository - Email verification sent to ${user.email}");
    } catch (e) {
      dev.log("AuthRepository - sendEmailVerification error: $e");
      rethrow;
    }
  }

  // Lưu thông tin user vào Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
      dev.log("AuthRepository - User data saved to Firestore: ${user.uid}");
    } catch (e) {
      dev.log("AuthRepository - saveUserData error: $e");
      rethrow;
    }
  }

  // Lấy dữ liệu user từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      dev.log("AuthRepository - getUserData error: $e");
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}
