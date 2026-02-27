# 04 - Dependency Injection

L'application utilise l'injection de dépendances via **GetIt** et l'outil de génération de code **Injectable**.

## Fonctionnement Global
L'objectif est d'empêcher les instanciations manuelles directes comme `GroupBloc(repository: GroupRepository())` partout dans le code, en déléguant au conteneur DI la résolution des arbres de dépendance.

### Fichier Configuration
Le cœur d'initialisation se trouve dans : `lib/src/shared/infrastructure/di/injection.dart`.

### Annotations Communes (`injectable`)

- `@lazySingleton` : Utilisé pour les dépôts (ex: `GroupRepository`), pour s'assurer qu'il n'y as qu'une seule instance créée, partagée par toute l'application. Elle est créée au moment de sa première utilisation.
- `@injectable` : Utilisé pour les Blocs de gestion d'états localisés et les cas d'utilisation (ex: `GroupBloc`). Cela permet d'obtenir une nouvelle instance propre lorsqu'une page est montée (utile pour réinitialiser les états).

## Génération
Pour mettre à jour les injections, exécutez la commande suivante à chaque modification :

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Utilisation
Partout dans l'interface, on accède aux implémentations injectées via `getIt<MonType>()` (ex: `getIt<GroupBloc>()`).
