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

  const CreateGroup({required this.name, required this.color});

  @override
  List<Object> get props => [name, color];
}
