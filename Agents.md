Agents.md - Règles du Projet InternatApp (Version Finale)
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

