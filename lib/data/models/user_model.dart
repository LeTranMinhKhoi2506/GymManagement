class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'admin' or 'user'

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}
