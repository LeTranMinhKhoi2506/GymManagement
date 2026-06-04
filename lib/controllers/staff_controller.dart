import 'package:flutter/material.dart';
import '../data/repository/staff_repository.dart';
import '../data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class StaffController extends ChangeNotifier {
  final StaffRepository _repository = StaffRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Stream<List<UserModel>> get staffStream => _repository.getStaffStream();

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

  Future<void> addStaff({
    required String fullName,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newStaff = UserModel(
        uid: const Uuid().v4(),
        email: email,
        fullName: fullName,
        role: 'staff',
        status: 'active',
        createdAt: DateTime.now(),
      );
      await _repository.addStaff(newStaff);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error adding staff: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStaffExtended({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String position,
    required double salary,
    required String address,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newStaff = UserModel(
        uid: const Uuid().v4(),
        email: email,
        fullName: fullName,
        role: 'staff',
        status: status,
        phoneNumber: phoneNumber,
        position: position,
        salary: salary,
        address: address,
        createdAt: DateTime.now(),
      );
      await _repository.addStaff(newStaff);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error adding staff: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStaff(UserModel staff) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateStaff(staff);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint("Error updating staff: $e");
      rethrow;
    }
  }

  Future<void> deleteStaff(String uid) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteStaff(uid);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint("Error deleting staff: $e");
      rethrow;
    }
  }
}
