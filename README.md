# InternatApp

Application Flutter de gestion de l'internat (Pointage, Groupes, Élèves, Activités).

## Architecture

L'application repose strictement sur l'architecture **FSD (Feature-Sliced Design)** et embarque **Clean Architecture** au niveau des features. Consultez les documentations suivantes pour comprendre l'implémentation complète :

- [01_functional_overview.md](doc/01_functional_overview.md) : Flux métier et fonctionnalités globales.
- [02_technical_architecture.md](doc/02_technical_architecture.md) : Détails FSD/Clean Architecture.
- [03_project_structure.md](doc/03_project_structure.md) : Arborescence de `lib/` et règles de placement de fichiers.
- [04_dependency_injection.md](doc/04_dependency_injection.md) : Modèle d'injection (GetIt + Injectable).
- [05_firebase_backend.md](doc/05_firebase_backend.md) : Intégration Supabase.
- [06_styling_and_theming.md](doc/06_styling_and_theming.md) : Moteur de thème et Responsive.
- [07_security.md](doc/07_security.md) : Sécurité et accès aux données.
- [08_testing_strategy.md](doc/08_testing_strategy.md) : Démarche et scope de tests.
- [09_deployment_and_environment.md](doc/09_deployment_and_environment.md) : Gestion des environnements et CI/CD.

*(Consultez [Agents.md](Agents.md) pour les règles fondamentales du code piloté par agents).*
