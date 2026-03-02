import 'package:equatable/equatable.dart';
import '../../domain/entities/student_entity.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentsInitial extends StudentState {}

class StudentsLoading extends StudentState {}

class StudentsLoaded extends StudentState {
  final List<StudentEntity> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentsError extends StudentState {
  final String message;

  const StudentsError(this.message);

  @override
  List<Object?> get props => [message];
}
