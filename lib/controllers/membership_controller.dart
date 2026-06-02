import 'package:flutter/material.dart';
import '../data/models/membership_plan_model.dart';
import '../data/repository/membership_repository.dart';

enum MembershipSortOption { name, price, duration }

class MembershipController extends ChangeNotifier {
  final MembershipRepository _repository = MembershipRepository();
  
  List<MembershipPlan> _allPlans = [];
  List<MembershipPlan> _filteredPlans = [];
  
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  bool? _isActiveFilter; // null = all, true = active, false = archived
  MembershipSortOption _sortOption = MembershipSortOption.name;
  bool _isAscending = true;

  List<MembershipPlan> get plans => _filteredPlans;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _minPrice != null || _maxPrice != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MembershipController() {
    _init();
  }

  void _init() {
    _repository.getMembershipPlans().listen((event) {
      _allPlans = event;
      _applyFilters();
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setPriceFilter(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(bool? isActive) {
    _isActiveFilter = isActive;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(MembershipSortOption option) {
    if (_sortOption == option) {
      _isAscending = !_isAscending;
    } else {
      _sortOption = option;
      _isAscending = true;
    }
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _minPrice = null;
    _maxPrice = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPlans = _allPlans.where((plan) {
      final matchesSearch = plan.name.toLowerCase().contains(_searchQuery) || 
                           plan.description.toLowerCase().contains(_searchQuery);
      final matchesMinPrice = _minPrice == null || plan.price >= _minPrice!;
      final matchesMaxPrice = _maxPrice == null || plan.price <= _maxPrice!;
      final matchesStatus = _isActiveFilter == null || plan.isActive == _isActiveFilter;
      
      return matchesSearch && matchesMinPrice && matchesMaxPrice && matchesStatus;
    }).toList();

    // Sắp xếp
    _filteredPlans.sort((a, b) {
      int cmp;
      switch (_sortOption) {
        case MembershipSortOption.name:
          cmp = a.name.compareTo(b.name);
          break;
        case MembershipSortOption.price:
          cmp = a.price.compareTo(b.price);
          break;
        case MembershipSortOption.duration:
          cmp = a.durationMonths.compareTo(b.durationMonths);
          break;
      }
      return _isAscending ? cmp : -cmp;
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
