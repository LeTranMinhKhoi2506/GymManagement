import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/equipment_model.dart';
import '../data/repository/equipment_repository.dart';

class EquipmentController extends ChangeNotifier {
  final EquipmentRepository _repository = EquipmentRepository();

  List<EquipmentModel> _equipment = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EquipmentModel> get equipment => _equipment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<EquipmentModel> get overdueMaintenance {
    final now = DateTime.now();
    return _equipment
        .where((e) => e.nextMaintenanceDate.isBefore(now))
        .toList();
  }

  List<EquipmentModel> get upcomingMaintenance {
    final now = DateTime.now();
    final upcoming = now.add(const Duration(days: 7));
    return _equipment
        .where((e) =>
            e.nextMaintenanceDate.isAfter(now) &&
            e.nextMaintenanceDate.isBefore(upcoming))
        .toList();
  }

  Future<void> fetchAllEquipment() async {
    _setLoading(true);
    _clearError();
    try {
      _equipment = await _repository.getAllEquipment();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createEquipment({
    required String name,
    required String category,
    required String status,
    String? serialNumber,
    String? location,
    required DateTime purchaseDate,
    required int maintenanceIntervalDays,
    String? notes,
    required String createdBy,
  }) async {
    _clearError();
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final equipment = EquipmentModel(
        id: uuid.v4(),
        name: name,
        category: category,
        status: status,
        serialNumber: serialNumber,
        location: location,
        purchaseDate: purchaseDate,
        lastMaintenanceDate: now,
        nextMaintenanceDate: now.add(Duration(days: maintenanceIntervalDays)),
        maintenanceIntervalDays: maintenanceIntervalDays,
        notes: notes,
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
      );
      await _repository.createEquipment(equipment);
      await fetchAllEquipment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateEquipment(EquipmentModel equipment) async {
    _clearError();
    try {
      final updated = equipment.copyWith(updatedAt: DateTime.now());
      await _repository.updateEquipment(updated);
      await fetchAllEquipment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteEquipment(String id) async {
    _clearError();
    try {
      await _repository.deleteEquipment(id);
      await fetchAllEquipment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> markMaintenanceCompleted(EquipmentModel equipment) async {
    _clearError();
    try {
      final now = DateTime.now();
      final updated = equipment.copyWith(
        lastMaintenanceDate: now,
        nextMaintenanceDate:
            now.add(Duration(days: equipment.maintenanceIntervalDays)),
        updatedAt: now,
      );
      await _repository.updateEquipment(updated);
      await fetchAllEquipment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
