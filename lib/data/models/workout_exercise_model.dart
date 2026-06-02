class WorkoutExerciseModel {
  WorkoutExerciseModel({
    required this.name,
    required this.sets,
    required this.reps,
  });

  final String name;
  final int sets;
  final int reps;

  WorkoutExerciseModel copyWith({String? name, int? sets, int? reps}) {
    return WorkoutExerciseModel(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'sets': sets, 'reps': reps};
  }

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseModel(
      name: (map['name'] as String?) ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
    );
  }
}

enum SocialMediaType { image, video }

class SocialMediaModel {
  SocialMediaModel({required this.path, required this.type});

  final String path;
  final SocialMediaType type;

  SocialMediaModel copyWith({String? path, SocialMediaType? type}) {
    return SocialMediaModel(path: path ?? this.path, type: type ?? this.type);
  }

  Map<String, dynamic> toMap() {
    return {'path': path, 'type': type.name};
  }

  factory SocialMediaModel.fromMap(Map<String, dynamic> map) {
    final rawType = (map['type'] as String?) ?? 'image';
    final parsed = SocialMediaType.values.where((e) => e.name == rawType);
    return SocialMediaModel(
      path: (map['path'] as String?) ?? '',
      type: parsed.isEmpty ? SocialMediaType.image : parsed.first,
    );
  }
}
