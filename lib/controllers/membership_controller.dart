import 'package:flutter/material.dart';
import '../data/models/membership_plan_model.dart';
import '../data/repository/membership_repository.dart';

class MembershipController extends ChangeNotifier {
  final MembershipRepository _repository = MembershipRepository();
  
  List<MembershipPlan> _plans = [];
  List<MembershipPlan> get plans => _plans;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MembershipController() {
    _init();
  }

  void _init() {
    _repository.getMembershipPlans().listen((event) {
      _plans = event;
      notifyListeners();
    });
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addPlan(MembershipPlan plan) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.addPlan(plan);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePlan(MembershipPlan plan) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.updatePlan(plan);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlan(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.deletePlan(id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
