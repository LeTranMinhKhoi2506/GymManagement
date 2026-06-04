import 'package:flutter/material.dart';
import '../data/repository/user_repository.dart';
import '../data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class UserController extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Stream<List<UserModel>> get usersStream => _repository.getUsersStream();

  Future<bool> checkEmailExists(String email, {String? excludeUid}) async {
    try {
      _errorMessage = null;
      return await _repository.isEmailExists(email, excludeUid: excludeUid);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUser({
    required String fullName,
    required String email,
    required String role,
    required String status,
    String? phoneNumber,
    String? address,
    String? gender,
    String? position,
    double? salary,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newUser = UserModel(
        uid: const Uuid().v4(),
        email: email.trim(),
        fullName: fullName.trim(),
        role: role,
        status: status,
        phoneNumber: phoneNumber?.trim(),
        address: address?.trim(),
        gender: gender,
        position: position,
        salary: salary,
        createdAt: DateTime.now(),
      );
      await _repository.addUser(newUser);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error adding user: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateUser(user);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error updating user: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteUser(uid);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error deleting user: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
