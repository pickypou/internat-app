import '../../domain/entities/group_entity.dart';

/// Data model representing a Group, handling serialization.
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    required super.color,
  });

  /// Creates a GroupModel from a JSON map (Supabase).
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }

  /// Converts a GroupModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {'name': name, 'color': color};
  }
}
