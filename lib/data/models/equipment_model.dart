import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String category;
  final String status;
  final String? serialNumber;
  final String? location;
  final DateTime purchaseDate;
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final int maintenanceIntervalDays;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.serialNumber,
    this.location,
    required this.purchaseDate,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.maintenanceIntervalDays,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory EquipmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EquipmentModel(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'Khác',
      status: map['status'] ?? 'Operational',
      serialNumber: map['serialNumber'],
      location: map['location'],
      purchaseDate: map['purchaseDate'] != null
          ? (map['purchaseDate'] as Timestamp).toDate()
          : DateTime.now(),
      lastMaintenanceDate: map['lastMaintenanceDate'] != null
          ? (map['lastMaintenanceDate'] as Timestamp).toDate()
          : DateTime.now(),
      nextMaintenanceDate: map['nextMaintenanceDate'] != null
          ? (map['nextMaintenanceDate'] as Timestamp).toDate()
          : DateTime.now(),
      maintenanceIntervalDays:
          (map['maintenanceIntervalDays'] as num?)?.toInt() ?? 30,
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'status': status,
      'serialNumber': serialNumber,
      'location': location,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'lastMaintenanceDate': Timestamp.fromDate(lastMaintenanceDate),
      'nextMaintenanceDate': Timestamp.fromDate(nextMaintenanceDate),
      'maintenanceIntervalDays': maintenanceIntervalDays,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  EquipmentModel copyWith({
    String? id,
    String? name,
    String? category,
    String? status,
    String? serialNumber,
    String? location,
    DateTime? purchaseDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    int? maintenanceIntervalDays,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceIntervalDays:
          maintenanceIntervalDays ?? this.maintenanceIntervalDays,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
