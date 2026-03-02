import 'package:injectable/injectable.dart';
import '../repositories/stage_period_repository.dart';

/// Result of a calendar import operation.
class CalendarImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  const CalendarImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });
}

/// Parses tab-separated text and upserts stage periods into [class_schedules].
///
/// Expected format per line (tabs as separator):
///   ClassName \t Type \t StartDate(JJ/MM/AAAA) \t EndDate(JJ/MM/AAAA)
///
/// Example:
///   3eme-A \t STAGE \t 02/03/2026 \t 15/03/2026
///
/// • If a period with the same class_name + start_date already exists, it is
///   updated (upsert semantics).
/// • Lines with missing or invalid data are skipped and returned in [errors].
@injectable
class CalendarImportUseCase {
  final StagePeriodRepository _repository;

  CalendarImportUseCase(this._repository);

  Future<CalendarImportResult> call(String rawText) async {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CalendarImportResult(imported: 0, skipped: 0, errors: []);
    }

    int imported = 0;
    final errors = <String>[];
    int lineIndex = 0;

    for (final line in lines) {
      lineIndex++;
      try {
        final parts = line.split('\t');
        if (parts.length < 4) {
          errors.add(
            'Ligne $lineIndex : format invalide (4 colonnes attendues)',
          );
          continue;
        }

        final className = parts[0].trim();
        final type = parts[1].trim().toUpperCase(); // STAGE | ALTERNANCE | …
        final startDateStr = parts[2].trim();
        final endDateStr = parts[3].trim();

        if (className.isEmpty) {
          errors.add('Ligne $lineIndex : classe vide');
          continue;
        }

        final startDate = _parseDate(startDateStr);
        final endDate = _parseDate(endDateStr);

        if (startDate == null) {
          errors.add(
            'Ligne $lineIndex : date de début invalide "$startDateStr"',
          );
          continue;
        }
        if (endDate == null) {
          errors.add('Ligne $lineIndex : date de fin invalide "$endDateStr"');
          continue;
        }
        if (endDate.isBefore(startDate)) {
          errors.add(
            'Ligne $lineIndex : la date de fin est avant la date de début',
          );
          continue;
        }

        await _repository.upsertStagePeriod(
          className: className,
          type: type,
          startDate: startDate,
          endDate: endDate,
        );
        imported++;
      } catch (e) {
        errors.add('Ligne $lineIndex : erreur inattendue ($e)');
      }
    }

    return CalendarImportResult(
      imported: imported,
      skipped: errors.length,
      errors: errors,
    );
  }

  /// Parses a French date string "JJ/MM/AAAA" → DateTime (UTC midnight).
  /// Returns null if the format is unrecognised.
  static DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    // Try French format: DD/MM/YYYY
    final frParts = s.split('/');
    if (frParts.length == 3) {
      final day = int.tryParse(frParts[0]);
      final month = int.tryParse(frParts[1]);
      final year = int.tryParse(frParts[2]);
      if (day != null && month != null && year != null) {
        try {
          return DateTime.utc(year, month, day);
        } catch (_) {
          return null;
        }
      }
    }
    // Fallback: ISO 8601
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}

/// Expose the static parser for testing without needing DI.
DateTime? parseCalendarDate(String s) => CalendarImportUseCase._parseDate(s);
