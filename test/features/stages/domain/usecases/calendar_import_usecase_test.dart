// TDD test — CalendarImportUseCase
//
// Ces tests vérifient la logique de parsing et d'upsert du CalendarImportUseCase.
// Ils utilisent un stub manuel de StagePeriodRepository (pas de dépendance Supabase).

import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/stages/domain/entities/stage_period_entity.dart';
import 'package:internat_app/src/features/stages/domain/repositories/stage_period_repository.dart';
import 'package:internat_app/src/features/stages/domain/usecases/calendar_import_usecase.dart';

// ── Stub repository ────────────────────────────────────────────────────────────
class _StubRepository implements StagePeriodRepository {
  final List<Map<String, dynamic>> upserted = [];

  @override
  Future<List<StagePeriodEntity>> getStagePeriods() async => [];

  @override
  Future<void> upsertStagePeriod({
    required String className,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    upserted.add({
      'className': className,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
    });
  }
}

void main() {
  // ── Utilitaire : construit une entrée tab-séparée ──────────────────────────
  String line(String cls, String type, String start, String end) =>
      '$cls\t$type\t$start\t$end';

  group('CalendarImportUseCase — parsing et upsert', () {
    late _StubRepository repo;
    late CalendarImportUseCase useCase;

    setUp(() {
      repo = _StubRepository();
      useCase = CalendarImportUseCase(repo);
    });

    // ── [GREEN] Cas principal demandé ─────────────────────────────────────────
    test(
      'importe "3eme-A STAGE 02/03/2026 15/03/2026" → 1 période, table remplie',
      () async {
        final result = await useCase(
          line('3eme-A', 'STAGE', '02/03/2026', '15/03/2026'),
        );

        expect(result.imported, equals(1));
        expect(result.skipped, equals(0));
        expect(result.errors, isEmpty);

        expect(repo.upserted, hasLength(1));
        final row = repo.upserted.first;
        expect(row['className'], equals('3eme-A'));
        expect(row['type'], equals('STAGE'));
        expect(row['startDate'], equals(DateTime.utc(2026, 3, 2)));
        expect(row['endDate'], equals(DateTime.utc(2026, 3, 15)));
      },
    );

    test('plusieurs lignes → toutes importées', () async {
      final input = [
        line('3eme-A', 'STAGE', '02/03/2026', '15/03/2026'),
        line('3eme-B', 'ALTERNANCE', '09/03/2026', '20/03/2026'),
      ].join('\n');

      final result = await useCase(input);

      expect(result.imported, equals(2));
      expect(repo.upserted, hasLength(2));
    });

    test('texte vide → 0 ligne importée', () async {
      final result = await useCase('   ');
      expect(result.imported, equals(0));
      expect(repo.upserted, isEmpty);
    });

    test(
      'ligne avec moins de 4 colonnes → ignorée, erreur retournée',
      () async {
        final result = await useCase('3eme-A\tSTAGE\t02/03/2026');
        expect(result.imported, equals(0));
        expect(result.skipped, equals(1));
        expect(result.errors.first, contains('format invalide'));
      },
    );

    test('date de début invalide → ligne ignorée', () async {
      final result = await useCase(
        line('3eme-A', 'STAGE', 'PAS-UNE-DATE', '15/03/2026'),
      );
      expect(result.imported, equals(0));
      expect(result.errors.first, contains('date de début'));
    });

    test('date de fin invalide → ligne ignorée', () async {
      final result = await useCase(
        line('3eme-A', 'STAGE', '02/03/2026', 'PAS-UNE-DATE'),
      );
      expect(result.imported, equals(0));
      expect(result.errors.first, contains('date de fin'));
    });

    test('date de fin avant date de début → ligne ignorée', () async {
      final result = await useCase(
        line('3eme-A', 'STAGE', '15/03/2026', '02/03/2026'),
      );
      expect(result.imported, equals(0));
      expect(result.errors.first, contains('date de fin est avant'));
    });

    test('classe vide → ligne ignorée', () async {
      final result = await useCase(
        line('', 'STAGE', '02/03/2026', '15/03/2026'),
      );
      expect(result.imported, equals(0));
      expect(result.errors.first, contains('classe vide'));
    });

    test(
      'lignes mixtes (valides + invalides) → seules les valides importées',
      () async {
        final input = [
          line('3eme-A', 'STAGE', '02/03/2026', '15/03/2026'), // ✅
          line('', 'STAGE', '02/03/2026', '15/03/2026'), // ❌ classe vide
          line('3eme-B', 'ALTERNANCE', '09/03/2026', '20/03/2026'), // ✅
        ].join('\n');

        final result = await useCase(input);

        expect(result.imported, equals(2));
        expect(result.skipped, equals(1));
        expect(repo.upserted, hasLength(2));
      },
    );

    test('type normalisé en MAJUSCULES', () async {
      await useCase(line('3eme-A', 'stage', '02/03/2026', '15/03/2026'));
      expect(repo.upserted.first['type'], equals('STAGE'));
    });
  });

  group('parseCalendarDate', () {
    test('format JJ/MM/AAAA', () {
      expect(parseCalendarDate('02/03/2026'), equals(DateTime.utc(2026, 3, 2)));
    });
    test('format ISO 8601 fallback', () {
      expect(
        parseCalendarDate('2026-03-02'),
        equals(DateTime.parse('2026-03-02')),
      );
    });
    test('chaîne vide → null', () {
      expect(parseCalendarDate(''), isNull);
    });
    test('texte invalide → null', () {
      expect(parseCalendarDate('bonjour'), isNull);
    });
  });
}
