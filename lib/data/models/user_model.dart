import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'admin', 'staff', 'user'
  final String status; // 'active', 'inactive'
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? address;
  final String? position; // e.g., 'Trainer', 'Receptionist', 'Manager'
  final double? salary;
  final String? gender;
  final String? avatarUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.status = 'active',
    this.createdAt,
    this.phoneNumber,
    this.address,
    this.position,
    this.salary,
    this.gender,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'phoneNumber': phoneNumber,
      'address': address,
      'position': position,
      'salary': salary,
      'gender': gender,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'user',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      position: map['position'],
      salary: (map['salary'] as num?)?.toDouble(),
      gender: map['gender'],
      avatarUrl: map['avatarUrl'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    String? status,
    DateTime? createdAt,
    String? phoneNumber,
    String? address,
    String? position,
    double? salary,
    String? gender,
    String? avatarUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
