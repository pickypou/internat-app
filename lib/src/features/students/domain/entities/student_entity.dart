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
  final String? alt;

  const StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.roomNumber,
    required this.className,
    required this.groupId,
    this.alt,
  });

  StudentEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? roomNumber,
    String? className,
    String? groupId,
    String? alt,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roomNumber: roomNumber ?? this.roomNumber,
      className: className ?? this.className,
      groupId: groupId ?? this.groupId,
      alt: alt ?? this.alt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    roomNumber,
    className,
    groupId,
    alt,
  ];
}
