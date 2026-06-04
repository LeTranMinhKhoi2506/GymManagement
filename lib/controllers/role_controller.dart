import 'package:flutter/material.dart';
import '../data/models/role_model.dart';
import '../data/repository/role_repository.dart';

class RoleController extends ChangeNotifier {
  final RoleRepository _repository = RoleRepository();
  
  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RoleController() {
    _init();
  }

  void _init() {
    _repository.getRolesStream().listen((event) {
      _roles = event;
      notifyListeners();
    });
  }

  Future<void> addRole(String name, List<String> permissions) async {
    _isLoading = true;
    notifyListeners();
    try {
      final role = RoleModel(id: '', name: name, permissions: permissions);
      await _repository.addRole(role);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRole(RoleModel role) async {
    await _repository.updateRole(role);
  }

  Future<void> deleteRole(String id) async {
    await _repository.deleteRole(id);
  }
}
