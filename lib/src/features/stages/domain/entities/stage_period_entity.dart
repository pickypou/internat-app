import 'package:equatable/equatable.dart';

/// Represents a planned period for a class (PRESENCE, STAGE, ALTERNANCE…)
class StagePeriodEntity extends Equatable {
  final String id;
  final String className; // e.g. "3eme-A"
  final String type; // "PRESENCE" | "STAGE" | "ALTERNANCE"
  final DateTime startDate; // inclusive
  final DateTime endDate; // inclusive

  const StagePeriodEntity({
    required this.id,
    required this.className,
    required this.startDate,
    required this.endDate,
    this.type = 'PRESENCE',
  });

  @override
  List<Object?> get props => [id, className, type, startDate, endDate];
}
