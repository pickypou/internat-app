import 'package:equatable/equatable.dart';

/// Represents a "frozen" attendance record in the permanent legal archive.
/// All fields are stored as raw text so they survive student/group deletion.
class AttendanceArchiveEntity extends Equatable {
  final String id;
  final String studentId;
  final String groupId;

  // Frozen copies of student data at the time of archiving
  final String storedLastName;
  final String storedFirstName;
  final String storedClassName;
  final String storedRoomNumber;
  final String periodLabel;

  final DateTime checkDate;
  final String status; // 'Présent', 'Absent', 'Stage', 'Hors Quinzaine'
  final String? note;
  final DateTime archiveDate;

  const AttendanceArchiveEntity({
    required this.id,
    required this.studentId,
    required this.groupId,
    required this.storedLastName,
    required this.storedFirstName,
    required this.storedClassName,
    required this.storedRoomNumber,
    required this.periodLabel,
    required this.checkDate,
    required this.status,
    this.note,
    required this.archiveDate,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    groupId,
    storedLastName,
    storedFirstName,
    storedClassName,
    storedRoomNumber,
    periodLabel,
    checkDate,
    status,
    note,
    archiveDate,
  ];
}
