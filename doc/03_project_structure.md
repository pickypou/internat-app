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
    │   └── group_selection/         # Structure STRICTE Clean Arch / FSD
    │       ├── domain/
    │       │   ├── entities/        # Entités pures isolées
    │       │   ├── failures/        # Gestion des erreurs propre au domaine métier
    │       │   ├── repositories/    # Interfaces abstraites (ex: GroupRepository.dart)
    │       │   └── usecases/        # Cas d'utilisation de la feature pure métier
    │       ├── data/
    │       │   ├── datasources/     # Appels Base de Données / API externes
    │       │   ├── models/          # Conversions fromJson (hérite des entities)
    │       │   └── repositories/    # Implémentations concrètes (avec `@Injectable`)
    │       ├── presentation/
    │       │   ├── bloc/            # Logiciels d'état de la feature
    │       │   ├── pages/           # Pages métiers complètes liées au router (Scaffolds)
    │       │   └── widgets/         # Sections UI intelligentes ou idiotes propres à la feature
    │       └── group_selection_module.dart  # Définitions GoRouter pour cette feature
    └── shared/
            └── school_logo.dart
```

### Règles d'Intégration
- Tous les écrans complets vont dans `src/pages`.
- Chaque nouvelle fonctionnalité ayant sa propre donnée ou logique BLoC va dans `src/features`.
- Les widgets UI génériques (boutons cliquables standardisés) utilisés dans + de 2 features doivent être déplacés dans `src/shared/widgets/`.
