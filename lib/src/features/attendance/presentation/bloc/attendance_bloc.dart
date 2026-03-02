import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/error/failure.dart';
import '../../domain/usecases/get_attendances_usecase.dart';
import '../../domain/usecases/save_attendance_usecase.dart';
import '../../domain/usecases/delete_attendance_usecase.dart';
import '../../../students/domain/usecases/get_students_usecase.dart';
import '../../../students/domain/usecases/get_all_students_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

@injectable
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetStudentsUseCase getStudentsUseCase;
  final GetAllStudentsUseCase getAllStudentsUseCase;
  final GetAttendancesUseCase getAttendancesUseCase;
  final SaveAttendanceUseCase saveAttendanceUseCase;
  final DeleteAttendanceUseCase deleteAttendanceUseCase;

  AttendanceBloc({
    required this.getStudentsUseCase,
    required this.getAllStudentsUseCase,
    required this.getAttendancesUseCase,
    required this.saveAttendanceUseCase,
    required this.deleteAttendanceUseCase,
  }) : super(AttendanceInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<UpdateAttendance>(_onUpdateAttendance);
    on<DeleteAttendance>(_onDeleteAttendance);
  }

  Future<void> _onLoadAttendance(
    LoadAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final List<dynamic> students;
      if (event.groupId == kAppelDimancheGroupId) {
        students = await getAllStudentsUseCase(kPolSupGroupName);
      } else {
        students = await getStudentsUseCase(event.groupId);
      }
      final attendances = await getAttendancesUseCase(
        event.groupId,
        event.date,
      );
      emit(
        AttendanceLoaded(students: students.cast(), attendances: attendances),
      );
    } on Failure catch (failure) {
      emit(AttendanceError(failure.message));
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onUpdateAttendance(
    UpdateAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        final currentAttendances = List.of(currentState.attendances);
        final index = currentAttendances.indexWhere(
          (a) => a.studentId == event.attendance.studentId,
        );

        if (index != -1) {
          currentAttendances[index] = event.attendance;
        } else {
          currentAttendances.add(event.attendance);
        }

        emit(
          AttendanceLoaded(
            students: currentState.students,
            attendances: currentAttendances,
          ),
        );
      }

      final savedAttendance = await saveAttendanceUseCase(event.attendance);

      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        final currentAttendances = List.of(currentState.attendances);
        final index = currentAttendances.indexWhere(
          (a) => a.studentId == savedAttendance.studentId,
        );

        if (index != -1) {
          currentAttendances[index] = savedAttendance;
        } else {
          currentAttendances.add(savedAttendance);
        }

        emit(
          AttendanceLoaded(
            students: currentState.students,
            attendances: currentAttendances,
          ),
        );
      }
    } on Failure catch (failure) {
      emit(AttendanceError(failure.message));
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred during update: $e'));
    }
  }

  Future<void> _onDeleteAttendance(
    DeleteAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        final currentAttendances = List.of(currentState.attendances);
        currentAttendances.removeWhere((a) => a.id == event.attendanceId);
        emit(
          AttendanceLoaded(
            students: currentState.students,
            attendances: currentAttendances,
          ),
        );
      }
      await deleteAttendanceUseCase(event.attendanceId);
    } on Failure catch (failure) {
      emit(AttendanceError(failure.message));
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred during delete: $e'));
    }
  }
}
