import 'package:equatable/equatable.dart';

abstract class ArchivesEvent extends Equatable {
  const ArchivesEvent();

  @override
  List<Object?> get props => [];
}

class LoadArchives extends ArchivesEvent {}
