# Agents.md — Règles de développement InternatApp
<1. 🏗️ Architecture Générale (FSD + Clean Architecture)

L'application suit strictement :

Feature-Sliced Design (FSD)

Clean Architecture

Séparation stricte Domain / Data / Presentation

Chaque feature doit être :

Autonome

Découplée

Testable indépendamment

Sans dépendance vers une autre feature

1.2 Structure Obligatoire d'une Feature

lib/src/features/[feature_name]/

domain/
 ├── entities/
 ├── failures/
 ├── repositories/
 ├── services/
 └── usecases/

data/
 ├── datasources/
 ├── models/
 └── repositories/

presentation/
 ├── bloc/
 ├── pages/
 └── widgets/

module.dart
1.3 Règles Fondamentales

Le Domain ne dépend d'aucune autre couche.

Le Data implémente uniquement les interfaces du Domain.

La Presentation ne connaît jamais Supabase directement.

Aucun import croisé entre features.

Toute logique métier doit vivre dans domain/.

2. 💉 Injection de Dépendances (DI)

Utilisation obligatoire de GetIt + Injectable

Aucun new manuel dans l'application

Tous les services doivent être annotés :

@injectable
@lazySingleton
@singleton

Configuration centralisée dans :

lib/src/core/di/injection.dart
3. 🧠 State Management (Bloc Pattern Strict)

flutter_bloc obligatoire

equatable obligatoire

1 Bloc = 1 responsabilité

Interdictions

❌ Pas de logique métier dans l'UI

❌ Pas de navigation dans le Bloc

❌ Pas d'appel API dans le Bloc

Navigation via :

BlocListener

Callbacks UI

4. 🧱 Règles DRY & Architecture Métier
4.1 Anti-duplication

Toute fonction utilisée plus d'une fois doit être :

Transformée en Service métier
OU

Encapsulée dans un UseCase

Aucune duplication autorisée.

4.2 Convention de Nommage

Fichiers → snake_case.dart

Classes → PascalCase

Variables → camelCase

UseCases → Action + UseCase

Repositories → Nom + Repository

Implémentations → Nom + RepositoryImpl

5. 🎨 UI, Thème & Responsive (STRICT)
5.1 Thématisation

Interdictions :

❌ Hardcoded colors

❌ Hardcoded fonts

❌ Hardcoded font sizes

Obligatoire :

Theme.of(context)
context.textTheme
context.colorScheme
5.2 Branding

Background sombre : #121212

Titres : Roboto

Corps : Lato

5.3 Responsive Obligatoire

Chaque page doit fonctionner :

📱 Mobile

💻 Desktop

📲 Tablet

Obligatoire :

LayoutBuilder ou MediaQuery

Aucun overflow horizontal

Utilisation flexible de Expanded / Flexible

Aucun écran fixe en largeur.

6. 🛡️ RÈGLES DE PRÉSERVATION UI (STRICTES)
Interdictions absolues :

❌ Supprimer un bouton existant sans validation explicite

❌ Supprimer le bouton d'importation

❌ Supprimer le bouton "+"

❌ Modifier la structure par tableaux repliables

❌ Supprimer un FloatingActionButton existant

Obligations :

Les titres utilisent group.color

Les bordures utilisent group.color

La vue par classes (tableaux séparés) est la référence

Avant toute modification UI :

Vérifier qu’aucune action AppBar ou FAB n’est supprimée.

7. 🧪 TDD – RÈGLE PRIORITAIRE

Aucun code métier n'est considéré comme terminé sans test vert.

7.1 Tests obligatoires

Chaque UseCase → test unitaire

Chaque Service métier → test

Chaque parsing JSON → test

Structure miroir :

lib/src/features/x/domain/service.dart
→
test/features/x/domain/service_test.dart
7.2 Couverture minimale

Chaque test doit couvrir :

Cas nominal

Cas limite (liste vide, null, date invalide…)

7.3 Interdictions

❌ Aucun commit si flutter analyze en erreur

❌ Aucun commit si flutter test rouge

8. 🗄️ Data & Backend

Backend : Supabase

SDK : supabase_flutter

Aucune logique de sécurité côté client uniquement

Toutes les restrictions doivent être garanties par :

RLS (Row Level Security)

8.1 Interdictions

❌ Appel Supabase dans l'UI

❌ Appel Supabase dans un Widget

❌ Accès direct à Supabase hors Datasource

9. ⚡ Performance

Obligatoire :

const constructors

Séparer gros widgets

Utiliser BlocSelector si pertinent

Éviter rebuilds globaux

Pas de calcul lourd dans build()

10. 📚 Documentation Obligatoire

À chaque évolution majeure :

Mettre à jour :

README.md
doc/01_functional_overview.md
doc/02_technical_architecture.md
doc/03_project_structure.md
doc/04_dependency_injection.md
doc/05_supabase_backend.md
doc/07_security.md
doc/08_testing_strategy.md
doc/09_deployment_and_environment.md

Aucune feature majeure sans documentation.

11. 🔄 Workflow Git

Une branche par feature

PR obligatoire

Tests verts avant merge

Conventional commits recommandés :

feat:
fix:
refactor:
test:
docs:
12. 🚨 RÈGLE DE NON-RÉGRESSION ABSOLUE

Toute nouvelle fonctionnalité doit :

S’ajouter à l’existant

Ne jamais remplacer un système existant

Ne jamais simplifier la structure sans validation

L'objectif est la stabilité long terme.