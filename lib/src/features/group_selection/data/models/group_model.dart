import '../../domain/entities/group_entity.dart';

/// Data model representing a Group, handling serialization.
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    required super.color,
    super.isPoleSup = false,
    super.studentCount = 0,
  });

  /// Creates a GroupModel from a JSON map (Supabase).
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['students'] != null && json['students'] is List) {
      final studentsList = json['students'] as List;
      if (studentsList.isNotEmpty && studentsList[0] is Map) {
        count = (studentsList[0]['count'] as num?)?.toInt() ?? 0;
      }
    } else if (json['student_count'] != null) {
      count = (json['student_count'] as num).toInt();
    }

    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      isPoleSup: json['is_pole_sup'] as bool? ?? false,
      studentCount: count,
    );
  }

  /// Converts a GroupModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'is_pole_sup': isPoleSup,
      // Note: we don't save studentCount back to the DB, it's a computed field.
    };
  }
}
