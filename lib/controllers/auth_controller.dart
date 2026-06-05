import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repository/auth_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/session_model.dart';
import '../data/repository/session_repository.dart';
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
          // Kiểm tra xem đã có tài khoản mẫu được nạp bằng email này chưa
          final emailQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email ?? email)
              .limit(1)
              .get();

          if (emailQuery.docs.isNotEmpty) {
            final seededDoc = emailQuery.docs.first;
            final seededData = seededDoc.data();
            final oldUid = seededDoc.id;
            
            // Sao chép dữ liệu mẫu sang UID thật và lưu vào Firestore
            _currentUser = UserModel.fromMap({
              ...seededData,
              'uid': user.uid,
            });
            await _repository.saveUserData(_currentUser!);

            // Xóa tài liệu mẫu cũ đi để tránh trùng lặp và cập nhật các tham chiếu
            if (oldUid != user.uid) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(oldUid)
                  .delete();
              
              // Đồng bộ các bảng liên kết từ UID cũ sang UID thật
              await _updateUserReferences(oldUid, user.uid);
            }
          } else {
            _currentUser = UserModel(
              uid: user.uid,
              email: user.email ?? email,
              fullName: user.displayName ?? "User từ Firebase",
              role: kIsWeb ? 'admin' : 'user',
            );
            await _repository.saveUserData(_currentUser!);
          }
        }

        // Ghi lại Session đăng nhập (Session Management)
        await _sessionRepository.logSession(
          SessionModel(
            id: '',
            userId: _currentUser!.uid,
            userName: _currentUser!.fullName,
            device: kIsWeb ? "Web Browser" : "Mobile App",
            ipAddress: "192.168.1.1", // Trong thực tế sẽ lấy IP thật
            loginAt: DateTime.now(),
          ),
        );

        _setLoading(false);
        notifyListeners();
        return {
          "status": "success",
          "user": _currentUser,
          "route": _resolveLandingRoute(_currentUser),
        };
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

  // Cập nhật tham chiếu UID mẫu của huấn luyện viên / hội viên sang UID thật của Firebase Auth
  Future<void> _updateUserReferences(String oldUid, String newUid) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    int ops = 0;

    try {
      // 1. pt_classes: Cập nhật ptId
      final classesQuery = await firestore
          .collection('pt_classes')
          .where('ptId', isEqualTo: oldUid)
          .get();
      for (var doc in classesQuery.docs) {
        batch.update(doc.reference, {'ptId': newUid});
        ops++;
      }

      // 2. schedules: Cập nhật staffUid
      final schedulesQuery = await firestore
          .collection('schedules')
          .where('staffUid', isEqualTo: oldUid)
          .get();
      for (var doc in schedulesQuery.docs) {
        batch.update(doc.reference, {'staffUid': newUid});
        ops++;
      }

      // 3. pt_activities: Cập nhật ptId
      final activitiesQuery = await firestore
          .collection('pt_activities')
          .where('ptId', isEqualTo: oldUid)
          .get();
      for (var doc in activitiesQuery.docs) {
        batch.update(doc.reference, {'ptId': newUid});
        ops++;
      }

      // 4. checkins: Cập nhật memberId
      final checkinsQuery = await firestore
          .collection('checkins')
          .where('memberId', isEqualTo: oldUid)
          .get();
      for (var doc in checkinsQuery.docs) {
        batch.update(doc.reference, {'memberId': newUid});
        ops++;
      }

      // 5. payments: Cập nhật memberId
      final paymentsQuery = await firestore
          .collection('payments')
          .where('memberId', isEqualTo: oldUid)
          .get();
      for (var doc in paymentsQuery.docs) {
        batch.update(doc.reference, {'memberId': newUid});
        ops++;
      }

      // 6. transactions: Cập nhật relatedMemberId
      final transactionsQuery = await firestore
          .collection('transactions')
          .where('relatedMemberId', isEqualTo: oldUid)
          .get();
      for (var doc in transactionsQuery.docs) {
        batch.update(doc.reference, {'relatedMemberId': newUid});
        ops++;
      }

      // 7. feedbacks: Cập nhật userId
      final feedbacksQuery = await firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: oldUid)
          .get();
      for (var doc in feedbacksQuery.docs) {
        batch.update(doc.reference, {'userId': newUid});
        ops++;
      }

      // 8. students: Cập nhật ptId và memberId
      final studentsPtQuery = await firestore
          .collection('students')
          .where('ptId', isEqualTo: oldUid)
          .get();
      for (var doc in studentsPtQuery.docs) {
        batch.update(doc.reference, {'ptId': newUid});
        ops++;
      }

      final studentsMemberQuery = await firestore
          .collection('students')
          .where('memberId', isEqualTo: oldUid)
          .get();
      for (var doc in studentsMemberQuery.docs) {
        batch.update(doc.reference, {'memberId': newUid});
        ops++;
      }

      // 9. pt_progress: Cập nhật ptId
      final progressQuery = await firestore
          .collection('pt_progress')
          .where('ptId', isEqualTo: oldUid)
          .get();
      for (var doc in progressQuery.docs) {
        batch.update(doc.reference, {'ptId': newUid});
        ops++;
      }

      // Thực thi batch update các tham chiếu
      if (ops > 0) {
        await batch.commit();
      }

      // 10. members: Sao chép document sang ID mới và xóa document cũ
      final memberDoc = await firestore.collection('members').doc(oldUid).get();
      if (memberDoc.exists) {
        final memberData = memberDoc.data()!;
        await firestore.collection('members').doc(newUid).set(memberData);
        await firestore.collection('members').doc(oldUid).delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi cập nhật tham chiếu UID: $e");
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _resolveLandingRoute(UserModel? user) {
    if (user == null) return '/customer-home';

    final email = user.email.toLowerCase().trim();
    final role = user.role.toLowerCase().trim();
    final position = (user.position ?? '').toLowerCase().trim();

    if (role == 'admin' || email == 'admin@kinetic.com') return '/admin-dashboard';
    if (role == 'trainer' || position == 'trainer' || email.startsWith('pt.')) return '/pt-dashboard';
    if (role == 'receptionist' ||
        role == 'staff' ||
        position == 'receptionist' ||
        email.startsWith('receptionist.')) {
      return '/receptionist-dashboard';
    }
    return '/customer-home';
  }
}
