import 'package:equatable/equatable.dart';
import '../../domain/entities/group_entity.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object> get props => [];
}

class GroupsInitial extends GroupState {}

class GroupsLoading extends GroupState {}

class GroupsLoaded extends GroupState {
  final List<GroupEntity> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object> get props => [groups];
}

class GroupsError extends GroupState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object> get props => [message];
}
