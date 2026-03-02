# Agents.md — Règles de développement InternatApp
<!-- ci: rebuild with dart-define secrets fix (2026-03-02) -->
 (Version Finale)
1. Architecture & Structure (FSD + Clean Arch)
L'application doit suivre strictement le découpage Feature-Sliced Design (FSD). Chaque feature doit être autonome et découplée.

1.2. Anatomie d'une Feature (FSD + Clean Arch)
Chaque dossier dans src/features/[name]/ doit suivre cette structure :

domain/ : Le cœur de la feature (Indépendant de tout).

entities/ : Modèles de données métier.

failures/ : Gestion des erreurs métier.

repositories/ : Interfaces (abstract classes) des dépôts.

usecases/ : Logique métier spécifique (une classe par action).

data/ : L'implémentation technique.

datasources/ : Appels directs à Supabase.

models/ : DTO (Data Transfer Objects) avec fromJson/toJson.

repositories/ : Implémentations concrètes (ex: group_repository_impl.dart).

presentation/ : L'interface utilisateur.

bloc/ : Logic (Bloc, Event, State).

pages/ : Les écrans de la feature.

widgets/ : Composants privés à cette feature.

module.dart : Configuration du GoRouter pour cette feature spécifique.

2. Injection de Dépendances (DI)
Utilisation stricte de GetIt et Injectable.

Chaque Repository ou Service doit être annoté avec @injectable ou @lazySingleton.

L'initialisation se fait dans src/core/di/injection.dart.

3. State Management (Bloc Pattern)
Utilisation exclusive de flutter_bloc avec equatable pour l'immuabilité.

Séparation stricte : Events, States, et Bloc.

La logique de navigation ne doit pas être dans le Bloc (utiliser les callbacks ou les listeners).

4. Règles de Code & UI (DRY & Responsive)
Abstraction des Widgets (DRY) : Tout widget utilisé plus de deux fois doit être extrait dans src/shared/widgets/ avec le préfixe Custom (ex: CustomCard).

Thématisation : Interdiction de hardcoder des couleurs ou des polices. Utiliser context.textTheme ou Theme.of(context).

Branding : Respecter le thème sombre (background #121212) et les polices (Titres: Roboto, Corps: Lato).

Langues : Code en Anglais, Interface en Français.

5. Documentation Obligatoire
L'agent doit maintenir à jour le dossier doc/ à chaque évolution majeure :

README.md : Point d'entrée avec liens vers la doc.

01_functional_overview.md : Flux métier.

02_technical_architecture.md : Détails FSD/Clean Arch.

03_project_structure.md : Arborescence lib/.

04_dependency_injection.md : Configuration GetIt.

05_firebase_backend.md : Setup Firebase/Supabase.

07_security.md : Règles RLS.

08_testing_strategy.md : Stratégie de test.

09_deployment_and_environment.md : CI/CD GitHub Actions.

6. Data & Erreurs
Interactions Supabase via supabase_flutter.

Pas d'appels API directs dans l'UI.

Gestion d'erreurs via des Failures explicites.


### 🛡️ RÈGLES DE PRÉSERVATION (STRICTES)

1. Interdiction de Suppression : Ne jamais supprimer un élément d'UI existant (boutons, icônes d'import, colonnes) sans une demande explicite de l'utilisateur.
2. Persistance des Fonctions : Le bouton d'ajout manuel (+), l'icône d'importation massive et le système de tri alphabétique doivent être maintenus à chaque itération.
3. Structure du Tableau : La vue par classes (Tableaux séparés et repliables) est la structure de référence. Ne pas revenir à une liste simple.
4. Thème Visuel : Les bordures et titres doivent toujours utiliser la couleur du groupe (group.color).
5. Validation : Avant de modifier un fichier presentation, vérifie que tu ne supprimes pas un FloatingActionButton ou une action dans l' AppBar.

### 🚨 CONSIGNES DE NON-RÉGRESSION
Il est formellement interdit de supprimer le bouton d'importation, le bouton d'ajout (+), ou de modifier la structure de tableaux séparés par classe sans validation. Chaque nouvelle fonctionnalité doit s'ajouter à l'existant, pas le remplacer.

### 🧪 RÈGLE TDD (TEST-DRIVEN DEVELOPMENT) — PRIORITAIRE

**Aucun code métier ne peut être considéré comme terminé sans son test associé au vert.**

1. **Tests d'abord** : Écrire le test unitaire ou d'intégration *avant* le code de production.
2. **Couverture obligatoire** : Toute nouvelle `UseCase`, tout service de domaine et toute logique de parsing doit avoir un test dans `test/features/[feature]/`.
3. **Aucune régression** : Chaque PR doit passer `flutter test` sans erreur.
4. **Périmètre minimal** : Un test doit couvrir au minimum le cas nominal + un cas limite (ex: liste vide, date hors-période).
5. **Structure miroir** : Les fichiers de test suivent la même arborescence que `lib/src/` (ex: `lib/src/features/stages/domain/services/stage_period_service.dart` → `test/features/stages/domain/services/stage_period_service_test.dart`).
6. **Aucun commit avec erreur** : Aucun code ne doit être poussé (commit/push) si `flutter analyze` ou `flutter test` retourne une erreur. Corriger d'abord, pousser ensuite.
