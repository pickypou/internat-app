import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../domain/usecases/delete_group_usecase.dart';
import '../../domain/usecases/rename_group_usecase.dart';
import '../../../../shared/error/failure.dart';
import 'group_event.dart';
import 'group_state.dart';

/// Bloc managing the state for group selection.
@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final RenameGroupUseCase renameGroupUseCase;

  GroupBloc(
    this.getGroupsUseCase,
    this.createGroupUseCase,
    this.deleteGroupUseCase,
    this.renameGroupUseCase,
  ) : super(GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroup>(_onCreateGroup);
    on<DeleteGroup>(_onDeleteGroup);
    on<RenameGroup>(_onRenameGroup);
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
      await createGroupUseCase(event.name, event.color, isPoleSup: event.isPoleSup);
      add(LoadGroups());
    } on Failure catch (failure) {
      emit(GroupsError(failure.message));
    } catch (e) {
      emit(GroupsError('An unexpected error occurred during creation: $e'));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroup event,
    Emitter<GroupState> emit,
  ) async {
    // Safety: never delete virtual or protected groups
    const protected = {'appel-dimanche', 'pol-sup'};
    if (protected.contains(event.groupId.toLowerCase())) {
      return; // silently refuse
    }
    emit(GroupsLoading());
    try {
      await deleteGroupUseCase(event.groupId);
      add(LoadGroups());
    } on Failure catch (failure) {
      emit(GroupsError(failure.message));
    } catch (e) {
      emit(GroupsError('An unexpected error occurred during deletion: $e'));
    }
  }

  Future<void> _onRenameGroup(
    RenameGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      await renameGroupUseCase(event.groupId, event.newName);
      add(LoadGroups());
    } on Failure catch (failure) {
      emit(GroupsError(failure.message));
    } catch (e) {
      emit(GroupsError('An unexpected error occurred during rename: $e'));
    }
  }
}
