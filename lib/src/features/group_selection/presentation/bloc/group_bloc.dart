import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../../../shared/error/failure.dart';
import 'group_event.dart';
import 'group_state.dart';

/// Bloc managing the state for group selection.
@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;

  GroupBloc(this.getGroupsUseCase, this.createGroupUseCase)
    : super(GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroup>(_onCreateGroup);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupState> emit) async {
    emit(GroupsLoading());
    try {
      final groups = await getGroupsUseCase();
      emit(GroupsLoaded(groups));
    } on Failure catch (failure) {
      emit(GroupsError(failure.message));
    } catch (e) {
      emit(GroupsError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      await createGroupUseCase(event.name, event.color);
      add(LoadGroups());
    } on Failure catch (failure) {
      emit(GroupsError(failure.message));
    } catch (e) {
      emit(GroupsError('An unexpected error occurred during creation: $e'));
    }
  }
}
