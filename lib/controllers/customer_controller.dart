import 'package:flutter/material.dart';
import '../data/models/member_model.dart';
import '../data/repository/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  final CustomerRepository _repository = CustomerRepository();
  
  List<MemberModel> _allMembers = [];
  List<MemberModel> _filteredMembers = [];
  String _filterStatus = 'All';
  String _searchQuery = '';
  MemberModel? _selectedMember;
  List<ActivityLog> _selectedMemberLogs = [];
  bool _isLoadingLogs = false;

  List<MemberModel> get members => _filteredMembers;
  List<MemberModel> get allMembers => _allMembers;
  String get filterStatus => _filterStatus;
  MemberModel? get selectedMember => _selectedMember;
  List<ActivityLog> get selectedMemberLogs => _selectedMemberLogs;
  bool get isLoadingLogs => _isLoadingLogs;

  CustomerController() {
    _init();
  }

  void _init() {
    _repository.getMembersStream().listen((members) {
      _allMembers = members;
      _applyFilters();
      
      // Select first member by default if none selected
      if (_selectedMember == null && _allMembers.isNotEmpty) {
        selectMember(_allMembers.first);
      } else if (_selectedMember != null) {
        // Update selected member if it was updated in the list
        try {
          _selectedMember = _allMembers.firstWhere((m) => m.id == _selectedMember!.id);
        } catch (_) {
          _selectedMember = _allMembers.isNotEmpty ? _allMembers.first : null;
        }
      }
      notifyListeners();
    });
  }

  void selectMember(MemberModel member) {
    _selectedMember = member;
    _fetchActivityLogs(member.id);
    notifyListeners();
  }

  void _fetchActivityLogs(String memberId) {
    _isLoadingLogs = true;
    notifyListeners();
    _repository.getActivityLogsStream(memberId).listen((logs) {
      _selectedMemberLogs = logs;
      _isLoadingLogs = false;
      notifyListeners();
    });
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMembers = _allMembers.where((member) {
      final matchesStatus = _filterStatus == 'All' || member.status == _filterStatus;
      final matchesSearch = member.fullName.toLowerCase().contains(_searchQuery) ||
          member.email.toLowerCase().contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addMember(MemberModel member) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addMember(member);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMember(MemberModel member) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateMember(member);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMember(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteMember(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
