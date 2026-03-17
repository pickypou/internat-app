import 'package:equatable/equatable.dart';

/// Pure domain entity representing a Group.
/// Does not contain backend serializations like fromJson.
class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final bool isPoleSup;
  final int studentCount;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.color,
    this.isPoleSup = false,
    this.studentCount = 0,
  });

  @override
  List<Object?> get props => [id, name, color, isPoleSup, studentCount];
}
