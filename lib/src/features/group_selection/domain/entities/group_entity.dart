import 'package:equatable/equatable.dart';

/// Pure domain entity representing a Group.
/// Does not contain backend serializations like fromJson.
class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String color;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}
