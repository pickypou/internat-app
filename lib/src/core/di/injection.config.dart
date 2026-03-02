// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/attendance/data/datasources/attendance_remote_datasource.dart'
    as _i425;
import '../../features/attendance/data/repositories/attendance_repository_impl.dart'
    as _i719;
import '../../features/attendance/domain/repositories/attendance_repository.dart'
    as _i477;
import '../../features/attendance/domain/usecases/delete_attendance_usecase.dart'
    as _i4;
import '../../features/attendance/domain/usecases/get_attendances_usecase.dart'
    as _i483;
import '../../features/attendance/domain/usecases/save_attendance_usecase.dart'
    as _i763;
import '../../features/attendance/presentation/bloc/attendance_bloc.dart'
    as _i700;
import '../../features/group_selection/data/datasources/group_remote_datasource.dart'
    as _i91;
import '../../features/group_selection/data/repositories/group_repository_impl.dart'
    as _i954;
import '../../features/group_selection/domain/repositories/group_repository.dart'
    as _i535;
import '../../features/group_selection/domain/usecases/create_group_usecase.dart'
    as _i1003;
import '../../features/group_selection/domain/usecases/delete_group_usecase.dart'
    as _i959;
import '../../features/group_selection/domain/usecases/get_groups_usecase.dart'
    as _i140;
import '../../features/group_selection/domain/usecases/global_import_usecase.dart'
    as _i791;
import '../../features/group_selection/domain/usecases/rename_group_usecase.dart'
    as _i1052;
import '../../features/group_selection/presentation/bloc/group_bloc.dart'
    as _i816;
import '../../features/stages/data/datasources/stage_period_remote_datasource.dart'
    as _i880;
import '../../features/stages/data/repositories/stage_period_repository_impl.dart'
    as _i981;
import '../../features/stages/domain/repositories/stage_period_repository.dart'
    as _i539;
import '../../features/stages/domain/usecases/calendar_import_usecase.dart'
    as _i328;
import '../../features/stages/domain/usecases/get_stage_periods_usecase.dart'
    as _i415;
import '../../features/students/data/datasources/student_remote_datasource.dart'
    as _i65;
import '../../features/students/data/repositories/student_repository_impl.dart'
    as _i865;
import '../../features/students/domain/repositories/student_repository.dart'
    as _i679;
import '../../features/students/domain/usecases/add_student_usecase.dart'
    as _i891;
import '../../features/students/domain/usecases/add_students_usecase.dart'
    as _i768;
import '../../features/students/domain/usecases/delete_student_usecase.dart'
    as _i965;
import '../../features/students/domain/usecases/delete_students_by_group_usecase.dart'
    as _i569;
import '../../features/students/domain/usecases/get_all_students_usecase.dart'
    as _i892;
import '../../features/students/domain/usecases/get_students_usecase.dart'
    as _i623;
import '../../features/students/domain/usecases/update_student_usecase.dart'
    as _i777;
import '../../features/students/presentation/bloc/student_bloc.dart' as _i1007;
import '../preferences/preferences_service.dart' as _i929;
import 'supabase_module.dart' as _i695;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final supabaseModule = _$SupabaseModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.lazySingleton<_i929.PreferencesService>(
      () => _i929.PreferencesService(),
    );
    gh.factory<_i91.GroupRemoteDataSource>(
      () => _i91.GroupRemoteDataSourceImpl(
        supabaseClient: gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i65.StudentRemoteDataSource>(
      () => _i65.StudentRemoteDataSourceImpl(
        supabaseClient: gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i892.GetAllStudentsUseCase>(
      () => _i892.GetAllStudentsUseCase(gh<_i65.StudentRemoteDataSource>()),
    );
    gh.factory<_i425.AttendanceRemoteDataSource>(
      () => _i425.AttendanceRemoteDataSourceImpl(
        supabaseClient: gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i477.AttendanceRepository>(
      () => _i719.AttendanceRepositoryImpl(
        gh<_i425.AttendanceRemoteDataSource>(),
      ),
    );
    gh.factory<_i679.StudentRepository>(
      () => _i865.StudentRepositoryImpl(gh<_i65.StudentRemoteDataSource>()),
    );
    gh.factory<_i880.StagePeriodRemoteDataSource>(
      () => _i880.StagePeriodRemoteDataSourceImpl(
        supabaseClient: gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i535.GroupRepository>(
      () => _i954.GroupRepositoryImpl(gh<_i91.GroupRemoteDataSource>()),
    );
    gh.factory<_i791.GlobalImportUseCase>(
      () => _i791.GlobalImportUseCase(
        gh<_i535.GroupRepository>(),
        gh<_i65.StudentRemoteDataSource>(),
      ),
    );
    gh.factory<_i4.DeleteAttendanceUseCase>(
      () => _i4.DeleteAttendanceUseCase(gh<_i477.AttendanceRepository>()),
    );
    gh.factory<_i891.AddStudentUseCase>(
      () => _i891.AddStudentUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i768.AddStudentsUseCase>(
      () => _i768.AddStudentsUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i965.DeleteStudentUseCase>(
      () => _i965.DeleteStudentUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i569.DeleteStudentsByGroupUseCase>(
      () => _i569.DeleteStudentsByGroupUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i623.GetStudentsUseCase>(
      () => _i623.GetStudentsUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i777.UpdateStudentUseCase>(
      () => _i777.UpdateStudentUseCase(gh<_i679.StudentRepository>()),
    );
    gh.factory<_i539.StagePeriodRepository>(
      () => _i981.StagePeriodRepositoryImpl(
        gh<_i880.StagePeriodRemoteDataSource>(),
      ),
    );
    gh.factory<_i483.GetAttendancesUseCase>(
      () => _i483.GetAttendancesUseCase(gh<_i477.AttendanceRepository>()),
    );
    gh.factory<_i763.SaveAttendanceUseCase>(
      () => _i763.SaveAttendanceUseCase(gh<_i477.AttendanceRepository>()),
    );
    gh.factory<_i1007.StudentBloc>(
      () => _i1007.StudentBloc(
        getStudentsUseCase: gh<_i623.GetStudentsUseCase>(),
        addStudentUseCase: gh<_i891.AddStudentUseCase>(),
        addStudentsUseCase: gh<_i768.AddStudentsUseCase>(),
        updateStudentUseCase: gh<_i777.UpdateStudentUseCase>(),
        deleteStudentUseCase: gh<_i965.DeleteStudentUseCase>(),
        deleteStudentsByGroupUseCase: gh<_i569.DeleteStudentsByGroupUseCase>(),
      ),
    );
    gh.factory<_i1003.CreateGroupUseCase>(
      () => _i1003.CreateGroupUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i140.GetGroupsUseCase>(
      () => _i140.GetGroupsUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i959.DeleteGroupUseCase>(
      () => _i959.DeleteGroupUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i1052.RenameGroupUseCase>(
      () => _i1052.RenameGroupUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i816.GroupBloc>(
      () => _i816.GroupBloc(
        gh<_i140.GetGroupsUseCase>(),
        gh<_i1003.CreateGroupUseCase>(),
        gh<_i959.DeleteGroupUseCase>(),
        gh<_i1052.RenameGroupUseCase>(),
      ),
    );
    gh.factory<_i700.AttendanceBloc>(
      () => _i700.AttendanceBloc(
        getStudentsUseCase: gh<_i623.GetStudentsUseCase>(),
        getAllStudentsUseCase: gh<_i892.GetAllStudentsUseCase>(),
        getAttendancesUseCase: gh<_i483.GetAttendancesUseCase>(),
        saveAttendanceUseCase: gh<_i763.SaveAttendanceUseCase>(),
        deleteAttendanceUseCase: gh<_i4.DeleteAttendanceUseCase>(),
      ),
    );
    gh.factory<_i328.CalendarImportUseCase>(
      () => _i328.CalendarImportUseCase(gh<_i539.StagePeriodRepository>()),
    );
    gh.factory<_i415.GetStagePeriodsUseCase>(
      () => _i415.GetStagePeriodsUseCase(gh<_i539.StagePeriodRepository>()),
    );
    return this;
  }
}

class _$SupabaseModule extends _i695.SupabaseModule {}
