import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/error/failure.dart';
import '../../domain/usecases/add_student_usecase.dart';
import '../../domain/usecases/add_students_usecase.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/delete_students_by_group_usecase.dart';
import 'student_event.dart';
import 'student_state.dart';

@injectable
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentsUseCase getStudentsUseCase;
  final AddStudentUseCase addStudentUseCase;
  final AddStudentsUseCase addStudentsUseCase;
  final UpdateStudentUseCase updateStudentUseCase;
  final DeleteStudentUseCase deleteStudentUseCase;
  final DeleteStudentsByGroupUseCase deleteStudentsByGroupUseCase;

  StudentBloc({
    required this.getStudentsUseCase,
    required this.addStudentUseCase,
    required this.addStudentsUseCase,
    required this.updateStudentUseCase,
    required this.deleteStudentUseCase,
    required this.deleteStudentsByGroupUseCase,
  }) : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<AddStudents>(_onAddStudents);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<DeleteStudentsByGroup>(_onDeleteStudentsByGroup);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      final students = await getStudentsUseCase(event.groupId);
      emit(StudentsLoaded(students));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(StudentsError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await addStudentUseCase(event.student);
      // Reload students for the same group after successful addition
      add(LoadStudents(event.student.groupId));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(StudentsError('An unexpected error occurred during creation: $e'));
    }
  }

  Future<void> _onAddStudents(
    AddStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await addStudentsUseCase(event.students);
      add(LoadStudents(event.groupId));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(
        StudentsError('An unexpected error occurred during bulk creation: $e'),
      );
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await updateStudentUseCase(event.student);
      add(LoadStudents(event.student.groupId));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(StudentsError('An unexpected error occurred during update: $e'));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await deleteStudentUseCase(event.studentId);
      add(LoadStudents(event.groupId));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(StudentsError('An unexpected error occurred during deletion: $e'));
    }
  }

  Future<void> _onDeleteStudentsByGroup(
    DeleteStudentsByGroup event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await deleteStudentsByGroupUseCase(event.groupId);
      emit(const StudentsLoaded([]));
    } on Failure catch (failure) {
      emit(StudentsError(failure.message));
    } catch (e) {
      emit(
        StudentsError('An unexpected error occurred during group clear: $e'),
      );
    }
  }
}
