// Smoke test — InternatApp
//
// Le test Flutter par défaut ("Counter increments") n'est pas applicable à
// cette app (pas de compteur, DI requis). Ce fichier le remplace par une
// vérification triviale qui garantit que la suite de tests peut s'exécuter.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smoke test — framework de test fonctionnel', () {
    // Pas de compteur dans InternatApp. Ce test vérifie uniquement que
    // flutter_test est opérationnel. Les tests métier sont dans test/features/.
    expect(1 + 1, equals(2));
  });
}
