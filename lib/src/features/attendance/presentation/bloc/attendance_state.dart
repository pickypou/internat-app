import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../students/domain/entities/student_entity.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<StudentEntity> students;
  final List<AttendanceEntity> attendances;

  const AttendanceLoaded({required this.students, required this.attendances});

  @override
  List<Object?> get props => [students, attendances];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
