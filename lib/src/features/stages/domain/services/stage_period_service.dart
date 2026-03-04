import '../entities/stage_period_entity.dart';

/// Pure domain service for stage/presence period logic.
/// No dependencies on Flutter or Supabase — fully unit-testable.
class StagePeriodService {
  StagePeriodService._(); // static-only utility class

  // ── Filtering helpers ──────────────────────────────────────────────────────

  /// Status of a class on a given date based on recorded periods.
  ///
  /// Logic (in priority order):
  ///   1. If a STAGE or ALTERNANCE period covers [date] → 'STAGE'
  ///   2. If a PRESENCE period covers [date]            → 'PRESENT'
  ///   3. No period found                               → 'HORS_QUINZAINE'
  static String classStatusOn(
    String className,
    DateTime date,
    List<StagePeriodEntity> periods,
  ) {
    final classKey = className.toLowerCase().trim();
    final d = _dateOnly(date);

    StagePeriodEntity? foundPresence;

    for (final p in periods) {
      if (p.className.toLowerCase().trim() != classKey) continue;
      final start = _dateOnly(p.startDate);
      final end = _dateOnly(p.endDate);
      if (d.isBefore(start) || d.isAfter(end)) continue;

      final t = p.type.toUpperCase();
      if (t == 'STAGE' || t == 'ALTERNANCE') {
        return 'STAGE'; // hidden — both types treated the same by the filter
      } else if (t == 'PRESENCE') {
        foundPresence = p;
      }
    }

    if (foundPresence != null) return 'PRESENT';
    return 'HORS_QUINZAINE'; // no period for this date → show normally
  }

  /// Returns true if [className] has an active STAGE/ALTERNANCE on [date].
  /// Start and end dates are **inclusive**.
  static bool isInStage(
    String className,
    DateTime date,
    List<StagePeriodEntity> periods,
  ) {
    return classStatusOn(className, date, periods) == 'STAGE';
  }

  /// Filters [students] to keep only those whose class is NOT in stage on [date].
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

  // ── Private helpers ────────────────────────────────────────────────────────
  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
