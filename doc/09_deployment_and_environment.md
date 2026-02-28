# 09 - Deployment and Environment

L'application doit fonctionner de manière automatisée lors de son déploiement ou du lancement d'outils de CI (Continuous Integration), gérés historiquement par **GitHub Actions**.

## Scripts & CI
- Chaque phase de construction (`build`) de master lance obligatoirement un script d'`analyze` strict pour bloquer toute inclusion de `print()` (laissé dans les controllers) et de dépendances mortes.
- Le CI vérifiera automatiquement les erreurs syntaxiques.

## Supabase (Environnement)
Dans ce projet, l'`url` et `anonKey` sont désormais sécurisées via un fichier `.env` en local (ignoré par Git). 

Pour le déploiement CI (GitHub Actions), il est **impératif** d'ajouter les variables d'environnement suivantes dans les **Settings > Secrets and variables > Actions** du repository GitHub :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Les workflows GitHub (e.g. `firebase-hosting-merge.yml`) sont ainsi configurés pour générer le fichier `.env` à la volée avant de lancer la compilation (le `flutter build`). Le code `main.dart` gère désormais ces variables en toute sécurité avec un bloc `try/catch` sur le chargement `dotenv`.
