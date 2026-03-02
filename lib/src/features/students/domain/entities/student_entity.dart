import 'package:equatable/equatable.dart';

/// Pure domain entity representing a Student.
/// Does not contain backend serializations like fromJson.
class StudentEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String roomNumber;
  final String className;
  final String groupId;

  const StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.roomNumber,
    required this.className,
    required this.groupId,
  });

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    roomNumber,
    className,
    groupId,
  ];
}
