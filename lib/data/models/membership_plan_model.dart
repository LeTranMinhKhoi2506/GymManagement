class MembershipPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final bool hasPT;
  final bool isActive;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    this.hasPT = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMonths': durationMonths,
      'hasPT': hasPT,
      'isActive': isActive,
    };
  }

  factory MembershipPlan.fromMap(Map<String, dynamic> map, String documentId) {
    return MembershipPlan(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationMonths: map['durationMonths'] ?? 1,
      hasPT: map['hasPT'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  MembershipPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMonths,
    bool? hasPT,
    bool? isActive,
  }) {
    return MembershipPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMonths: durationMonths ?? this.durationMonths,
      hasPT: hasPT ?? this.hasPT,
      isActive: isActive ?? this.isActive,
    );
  }
}
