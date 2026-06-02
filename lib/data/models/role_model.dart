class RoleModel {
  final String id;
  final String name;
  final List<String> permissions;

  RoleModel({required this.id, required this.name, required this.permissions});

  Map<String, dynamic> toMap() => {'name': name, 'permissions': permissions};
  
  factory RoleModel.fromMap(Map<String, dynamic> map, String id) => RoleModel(
    id: id,
    name: map['name'] ?? '',
    permissions: List<String>.from(map['permissions'] ?? []),
  );
}
