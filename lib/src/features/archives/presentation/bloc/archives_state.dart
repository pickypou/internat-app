import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_history_report.dart';

abstract class ArchivesState extends Equatable {
  const ArchivesState();

  @override
  List<Object?> get props => [];
}

class ArchivesInitial extends ArchivesState {}

class ArchivesLoading extends ArchivesState {}

class ArchivesLoaded extends ArchivesState {
  final List<AttendanceHistoryReport> reports;

  const ArchivesLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ArchivesError extends ArchivesState {
  final String message;

  const ArchivesError(this.message);

  @override
  List<Object?> get props => [message];
}
