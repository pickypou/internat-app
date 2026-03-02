# 03 - Project Structure

L'arborescence de `lib/` est régie par l'architecture FSD. Voici une vue globale :

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   └── routing/                 # Configuration globale de GoRouter (`app_router.dart`)
    ├── core/
    │   └── di/                      # Configuration de l'Injection de Dépendances Centrale (`injection.dart`)
    ├── entities/                    # Entités de base (abstractions pures)
    ├── features/
    │   ├── group_selection/         # Structure STRICTE Clean Arch / FSD
    │   │   ├── domain/
    │   │   ├── data/
    │   │   ├── presentation/
    │   │   └── group_selection_module.dart
    │   └── students/                # Nouvelle feature (Student Management)
    │       ├── domain/              # Entities, Repositories (Interfaces), UseCases
    │       ├── data/                # Models, Repositories (Impl), DataSources
    │       ├── presentation/        # StudentBloc, StudentListPage, AddStudentForm
    │       └── student_module.dart  # Définitions GoRouter pour cette feature
    └── shared/
            └── school_logo.dart
```

### Règles d'Intégration
- Tous les écrans complets vont dans `src/pages`.
- Chaque nouvelle fonctionnalité ayant sa propre donnée ou logique BLoC va dans `src/features`.
- Les widgets UI génériques (boutons cliquables standardisés) utilisés dans + de 2 features doivent être déplacés dans `src/shared/widgets/`.
