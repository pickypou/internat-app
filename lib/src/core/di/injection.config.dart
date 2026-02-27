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

import '../../features/group_selection/data/datasources/group_remote_datasource.dart'
    as _i91;
import '../../features/group_selection/data/repositories/group_repository_impl.dart'
    as _i954;
import '../../features/group_selection/domain/repositories/group_repository.dart'
    as _i535;
import '../../features/group_selection/domain/usecases/create_group_usecase.dart'
    as _i1003;
import '../../features/group_selection/domain/usecases/get_groups_usecase.dart'
    as _i140;
import '../../features/group_selection/presentation/bloc/group_bloc.dart'
    as _i816;
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
    gh.factory<_i91.GroupRemoteDataSource>(
      () => _i91.GroupRemoteDataSourceImpl(
        supabaseClient: gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i535.GroupRepository>(
      () => _i954.GroupRepositoryImpl(gh<_i91.GroupRemoteDataSource>()),
    );
    gh.factory<_i1003.CreateGroupUseCase>(
      () => _i1003.CreateGroupUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i140.GetGroupsUseCase>(
      () => _i140.GetGroupsUseCase(gh<_i535.GroupRepository>()),
    );
    gh.factory<_i816.GroupBloc>(
      () => _i816.GroupBloc(
        gh<_i140.GetGroupsUseCase>(),
        gh<_i1003.CreateGroupUseCase>(),
      ),
    );
    return this;
  }
}

class _$SupabaseModule extends _i695.SupabaseModule {}
