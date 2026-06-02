import 'package:flutter/material.dart';
import '../data/repository/staff_repository.dart';
import '../data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class StaffController extends ChangeNotifier {
  final StaffRepository _repository = StaffRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<UserModel>> get staffStream => _repository.getStaffStream();

  Future<bool> checkEmailExists(String email, {String? excludeUid}) async {
    return await _repository.isEmailExists(email, excludeUid: excludeUid);
  }

  Future<void> addStaff({
    required String fullName,
    required String email,
  }) async {
    _isLoading = true;
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
      debugPrint("Error adding staff: $e");
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
      debugPrint("Error adding staff: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStaff(UserModel staff) async {
    try {
      await _repository.updateStaff(staff);
    } catch (e) {
      debugPrint("Error updating staff: $e");
      rethrow;
    }
  }

  Future<void> deleteStaff(String uid) async {
    try {
      await _repository.deleteStaff(uid);
    } catch (e) {
      debugPrint("Error deleting staff: $e");
    }
  }
}
