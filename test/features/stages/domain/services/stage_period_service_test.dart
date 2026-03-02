import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/stages/domain/entities/stage_period_entity.dart';
import 'package:internat_app/src/features/stages/domain/services/stage_period_service.dart';

void main() {
  group('StagePeriodService', () {
    // ── Données de test ──────────────────────────────────────────────────────
    final stagePeriods = [
      StagePeriodEntity(
        id: 'sp1',
        className: '3eme-A',
        startDate: DateTime(2026, 3, 2), // 02/03/2026
        endDate: DateTime(2026, 3, 8), // 08/03/2026 (inclusive)
      ),
    ];

    // ── isInStage ─────────────────────────────────────────────────────────────
    group('isInStage', () {
      test('returns true when date is inside the stage period', () {
        final date = DateTime(2026, 3, 3); // 03/03/2026 ← inside period
        expect(
          StagePeriodService.isInStage('3eme-A', date, stagePeriods),
          isTrue,
        );
      });

      test('returns true on the first day of stage (inclusive boundary)', () {
        final date = DateTime(2026, 3, 2);
        expect(
          StagePeriodService.isInStage('3eme-A', date, stagePeriods),
          isTrue,
        );
      });

      test('returns true on the last day of stage (inclusive boundary)', () {
        final date = DateTime(2026, 3, 8);
        expect(
          StagePeriodService.isInStage('3eme-A', date, stagePeriods),
          isTrue,
        );
      });

      test('returns false when date is before the stage period', () {
        final date = DateTime(2026, 3, 1); // 01/03/2026 ← before
        expect(
          StagePeriodService.isInStage('3eme-A', date, stagePeriods),
          isFalse,
        );
      });

      test('returns false when date is after the stage period', () {
        final date = DateTime(2026, 3, 9); // 09/03/2026 ← after
        expect(
          StagePeriodService.isInStage('3eme-A', date, stagePeriods),
          isFalse,
        );
      });

      test('returns false for a different class not in stage', () {
        final date = DateTime(2026, 3, 3);
        expect(
          StagePeriodService.isInStage('3eme-B', date, stagePeriods),
          isFalse,
        );
      });

      test('returns false when stage periods list is empty', () {
        final date = DateTime(2026, 3, 3);
        expect(StagePeriodService.isInStage('3eme-A', date, []), isFalse);
      });

      test('is case-insensitive on class name', () {
        final date = DateTime(2026, 3, 3);
        expect(
          StagePeriodService.isInStage('3EME-A', date, stagePeriods),
          isTrue,
        );
      });
    });

    // ── filterActiveStudents ──────────────────────────────────────────────────
    group('filterActiveStudents', () {
      final students = [
        const _TestStudent('Alice', '3eme-A'),
        const _TestStudent('Bob', '3eme-B'),
        const _TestStudent('Claire', '3eme-A'),
      ];

      test('excludes students whose class is in stage on the given date', () {
        final date = DateTime(2026, 3, 3);
        final result = StagePeriodService.filterActiveStudents(
          students,
          (s) => s.className,
          date,
          stagePeriods,
        );
        expect(result.map((s) => s.name), containsAll(['Bob']));
        expect(result.map((s) => s.name), isNot(contains('Alice')));
        expect(result.map((s) => s.name), isNot(contains('Claire')));
      });

      test(
        'returns all students when no class is in stage on the given date',
        () {
          final date = DateTime(2026, 3, 10); // После stage
          final result = StagePeriodService.filterActiveStudents(
            students,
            (s) => s.className,
            date,
            stagePeriods,
          );
          expect(result.length, equals(3));
        },
      );

      test('returns all students when stage period list is empty', () {
        final date = DateTime(2026, 3, 3);
        final result = StagePeriodService.filterActiveStudents(
          students,
          (s) => s.className,
          date,
          [],
        );
        expect(result.length, equals(3));
      });
    });
  });
}

// Helper class for tests (not the real domain entity)
class _TestStudent {
  final String name;
  final String className;
  const _TestStudent(this.name, this.className);
}
