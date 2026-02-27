# 05 - Firebase / Supabase Backend

Bien que le titre mentionne Firebase, le projet InternatApp repose sur **Supabase** comme système backend exclusif et base de données relationnelle. Le package utilisé est `supabase_flutter`.

## Accès Base de Données
Chaque module de données dans l'application communique avec le backend à travers le concept de `Repository`. 

- **Séparation Stricte :** Le code d'UI n'est **jamais** autorisé à posséder une instance `SupabaseClient` ou à exécuter un insert/select.
- **Failures :** Toute erreur backend rencontrée dans un bloc `try-catch` au sein du Repository (e.g. un problème réseau ou clé non fonctionnelle) est convertie en une exception explicite nommée `ServerFailure`. Elle sera traitée de manière "safe" par le BLoC.

## Configuration Principale
Supabase est initialisé à la racine dans le `main.dart` de l'application via `Supabase.initialize()`. L'instance singleton de Supabase `Supabase.instance.client` est récupérable à tout endroit ayant besoin de configurer une communication HTTP.

L'ensemble des schémas de données reflètent exactement les entités déclarées dans `lib/src/entities/` (ex: la table `groups` de Supabase correspond directement à notre `GroupModel` via ses méthodes JSON).
