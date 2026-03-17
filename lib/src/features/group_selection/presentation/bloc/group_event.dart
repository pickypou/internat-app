import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupEvent {}

class CreateGroup extends GroupEvent {
  final String name;
  final String color;
  final bool isPoleSup;

  const CreateGroup({required this.name, required this.color, this.isPoleSup = false});

  @override
  List<Object> get props => [name, color, isPoleSup];
}

class DeleteGroup extends GroupEvent {
  final String groupId;
  const DeleteGroup(this.groupId);
  @override
  List<Object> get props => [groupId];
}

class RenameGroup extends GroupEvent {
  final String groupId;
  final String newName;
  const RenameGroup(this.groupId, this.newName);
  @override
  List<Object> get props => [groupId, newName];
}
