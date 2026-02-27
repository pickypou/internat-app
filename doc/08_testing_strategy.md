# 08 - Testing Strategy

La stratégie adoptée est la séparation stricte par couches (TDD - Test Driven Development lorsque pertinent).

## Scope BLoC
1. Test de l'émission initiale (State initial).
2. Test d'un flux réussi : Injection d'un Repository simulé (Mock), exécution de `LoadGroups`, puis attente de `[GroupsLoading, GroupsLoaded]`.
3. Test de rejet : Attente de `[GroupsLoading, GroupsError]`.

Les blocs ne testent aucune exécution de vue.

## Scope UI (Widget Testing)
- Création du Widget enveloppé dans le bloc avec `BlocProvider`.
- Assertions d'existence de texte (`find.text`).
- Interaction (`tester.tap` sur bouton).

## Outils Validés
- `flutter_test`
- L'utilisation massive de bibliothèques tierces non natives est déconseillée sans prérequis explicite, sauf l'implémentation de la bibliothèque standard `mocktail` (ou `mockito`) pour imiter Supabase et/ou Injectable.
