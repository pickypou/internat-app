// TDD RED — test/calendar_logic_test.dart
//
// Ce test définit le comportement attendu du système de calendrier :
// un élève d'une classe en stage doit être marqué "En Stage" pour les dates
// comprises dans la période de stage enregistrée.
//
// Il s'appuie sur StagePeriodService (déjà au vert) et illustre le contrat
// métier attendu pour l'intégration future avec la vue Calendrier.

import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/stages/domain/entities/stage_period_entity.dart';
import 'package:internat_app/src/features/stages/domain/services/stage_period_service.dart';

void main() {
  // ── Période de stage de référence ─────────────────────────────────────────
  final periods = [
    StagePeriodEntity(
      id: 'p1',
      className: '3eme-A',
      startDate: DateTime(2026, 3, 2), // 02/03/2026
      endDate: DateTime(2026, 3, 8), // 08/03/2026 inclus
    ),
  ];

  // ── Contrat : labelFor(className, date, periods) ──────────────────────────
  //
  // Règle métier :
  //   • Si la classe est en stage ce jour → "En Stage"
  //   • Sinon                             → "En École"
  //
  // Cette logique sera extraite dans CalendarLabelService (à créer).
  // Pour l'instant le test appelle StagePeriodService.isInStage directement.

  String labelFor(String className, DateTime date, List<StagePeriodEntity> ps) {
    return StagePeriodService.isInStage(className, date, ps)
        ? 'En Stage'
        : 'En École';
  }

  group('Calendrier — label En École / En Stage', () {
    test('[RED→GREEN] 3eme-A le 03/03/2026 est En Stage', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 3), periods);
      expect(label, equals('En Stage'));
    });

    test('3eme-A le 01/03/2026 (avant stage) est En École', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 1), periods);
      expect(label, equals('En École'));
    });

    test('3eme-A le 09/03/2026 (après stage) est En École', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 9), periods);
      expect(label, equals('En École'));
    });

    test('3eme-B (autre classe) le 03/03/2026 est En École', () {
      final label = labelFor('3eme-B', DateTime(2026, 3, 3), periods);
      expect(label, equals('En École'));
    });

    test('3eme-A le premier jour de stage (02/03) est En Stage', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 2), periods);
      expect(label, equals('En Stage'));
    });

    test('3eme-A le dernier jour de stage (08/03) est En Stage', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 8), periods);
      expect(label, equals('En Stage'));
    });

    test('Sans aucune période de stage configurée → toujours En École', () {
      final label = labelFor('3eme-A', DateTime(2026, 3, 3), []);
      expect(label, equals('En École'));
    });
  });
}
