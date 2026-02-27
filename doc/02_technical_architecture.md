# 02 - Technical Architecture

L'architecture de l'application suit les principes fondamentaux du **Feature-Sliced Design (FSD)**, combinée aux principes de la **Clean Architecture** au sein de la gestion des données (`Entities` et `Features`).

## Fondations Techniques

- **Framework** : Flutter
- **State Management** : BLoC (`flutter_bloc`), avec les états protégés par `equatable`. Le pattern BLoC dicte une isolation parfaite entre Events, States, et Bloc Logic.
- **Stockage de Données** : Supabase.

## L'architecture Feature-Sliced Design (FSD)

L'application est découpée horizontalement en couches de dépendances unilatérales (de haut en bas) :

1. **`app/`** : Composition globale (Router, Injecteur global, Thèmes racines).
2. **`pages/`** : L'assemblage des écrans complets orchestrant plusieurs features.
3. **`features/`** : La logique métier pure, encapsulée selon les règles strictes de la Clean Architecture. Chaque feature est structurée en :
   - `domain/` : Les contrats abstraits (interfaces de `repositories`) et entités propres à la feature (indépendant de toute technologie tierce).
   - `data/` : L'implémentation concrète (ex: `group_repository_impl.dart`) gérant les appels API Supabase. Fournie au domaine via l'injection de dépendances (`@Injectable(as: MonInterface)`).
   - `presentation/` : Divisée en `bloc/` (gestion d'états BLoC) et `widgets/` (composants visuels interactifs propres à la feature).
4. **`entities/`** : Les objets métiers de base (Models avec conversion JSON) et les abstractions cœur de l'entreprise partagées entre plusieurs features.
5. **`shared/`** : Code transversal n'ayant aucune logique métier d'application : Design System, utilitaires d'erreur générique, Configuration d'injection de dépendances, ou classes d'infrastructure et extensions.

*Règle stricte d'import* : Un module inférieur ne doit jamais importer un code lié à un module supérieur. Les features peuvent importer des "entities" et des ressources provenant de "shared", mais jamais vice versa.
