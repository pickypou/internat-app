import 'package:equatable/equatable.dart';

/// Represents a school internship/stage period for a given class.
class StagePeriodEntity extends Equatable {
  final String id;
  final String className; // e.g. "3eme-A"
  final DateTime startDate; // inclusive
  final DateTime endDate; // inclusive

  const StagePeriodEntity({
    required this.id,
    required this.className,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [id, className, startDate, endDate];
}
