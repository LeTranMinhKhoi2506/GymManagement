import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đăng ký với Email Verification
  Future<String?> signUp(String email, String password, String fullName, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Gửi email xác thực
        await user.sendEmailVerification();

        // Lưu thông tin user vào Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          role: role,
        );
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return "success";
      }
      return "Đã có lỗi xảy ra.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Mật khẩu quá yếu.';
      if (e.code == 'email-already-in-use') return 'Email này đã được sử dụng.';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng nhập và kiểm tra xác thực email
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        if (!user.emailVerified) {
          return {"status": "unverified", "message": "Vui lòng xác thực email trước khi đăng nhập."};
        }
        
        UserModel? userData = await getUserData(user.uid);
        if (userData != null) {
          return {"status": "success", "user": userData};
        }
      }
      return {"status": "error", "message": "Không tìm thấy dữ liệu người dùng."};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return {"status": "error", "message": "Email chưa được đăng ký."};
      if (e.code == 'wrong-password') return {"status": "error", "message": "Sai mật khẩu."};
      return {"status": "error", "message": e.message};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Gửi email đặt lại mật khẩu
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Firebase: Đã gửi yêu cầu reset tới $email");
      return "success";
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Error Code: ${e.code}"); // Xem mã lỗi tại đây
      debugPrint("Firebase Error Message: ${e.message}");
      if (e.code == 'user-not-found') return "Email này chưa được đăng ký.";
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Gửi lại email xác thực
  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Lấy thông tin user hiện tại từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Stream trạng thái đăng nhập
  Stream<User?> get userStream => _auth.authStateChanges();
}
