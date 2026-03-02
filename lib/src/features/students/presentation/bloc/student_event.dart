import 'package:equatable/equatable.dart';
import '../../domain/entities/student_entity.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentEvent {
  final String groupId;

  const LoadStudents(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class AddStudent extends StudentEvent {
  final StudentEntity student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class AddStudents extends StudentEvent {
  final List<StudentEntity> students;
  final String groupId;

  const AddStudents(this.students, this.groupId);

  @override
  List<Object?> get props => [students, groupId];
}

class UpdateStudent extends StudentEvent {
  final StudentEntity student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentEvent {
  final String studentId;
  final String groupId; // needed to refresh the list afterwards

  const DeleteStudent(this.studentId, this.groupId);

  @override
  List<Object?> get props => [studentId, groupId];
}

class DeleteStudentsByGroup extends StudentEvent {
  final String groupId;
  const DeleteStudentsByGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}
