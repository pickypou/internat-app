import '../entities/stage_period_entity.dart';

/// Pure domain service for stage period logic.
/// No dependencies on Flutter or Supabase — fully unit-testable.
class StagePeriodService {
  StagePeriodService._(); // static-only utility class

  /// Returns true if [className] has an active stage on [date].
  /// Start and end dates are **inclusive**.
  /// Class name comparison is case-insensitive.
  static bool isInStage(
    String className,
    DateTime date,
    List<StagePeriodEntity> periods,
  ) {
    final classKey = className.toLowerCase().trim();
    // Normalise date: compare only year/month/day
    final d = DateTime(date.year, date.month, date.day);

    return periods.any((p) {
      if (p.className.toLowerCase().trim() != classKey) return false;
      final start = DateTime(
        p.startDate.year,
        p.startDate.month,
        p.startDate.day,
      );
      final end = DateTime(p.endDate.year, p.endDate.month, p.endDate.day);
      return !d.isBefore(start) && !d.isAfter(end);
    });
  }

  /// Filters [students] to keep only those whose class is NOT in stage on [date].
  ///
  /// [getClassName] is a function that extracts the `className` field from [T],
  /// making this method generic and independent of the concrete student type.
  static List<T> filterActiveStudents<T>(
    List<T> students,
    String Function(T) getClassName,
    DateTime date,
    List<StagePeriodEntity> periods,
  ) {
    if (periods.isEmpty) return List<T>.from(students);
    return students
        .where((s) => !isInStage(getClassName(s), date, periods))
        .toList();
  }
}
