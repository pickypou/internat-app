import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendance extends AttendanceEvent {
  final String groupId;
  final DateTime date;

  const LoadAttendance(this.groupId, this.date);

  @override
  List<Object?> get props => [groupId, date];
}

class LoadPoleSupClasses extends AttendanceEvent {
  final DateTime date;

  const LoadPoleSupClasses(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateAttendance extends AttendanceEvent {
  final AttendanceEntity attendance;
  final String groupId;
  final DateTime date;

  const UpdateAttendance(this.attendance, this.groupId, this.date);

  @override
  List<Object?> get props => [attendance, groupId, date];
}

class DeleteAttendance extends AttendanceEvent {
  final String attendanceId;

  const DeleteAttendance(this.attendanceId);

  @override
  List<Object?> get props => [attendanceId];
}
