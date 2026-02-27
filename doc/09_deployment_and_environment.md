# 09 - Deployment and Environment

L'application doit fonctionner de manière automatisée lors de son déploiement ou du lancement d'outils de CI (Continuous Integration), gérés historiquement par **GitHub Actions**.

## Scripts & CI
- Chaque phase de construction (`build`) de master lance obligatoirement un script d'`analyze` strict pour bloquer toute inclusion de `print()` (laissé dans les controllers) et de dépendances mortes.
- Le CI vérifiera automatiquement les erreurs syntaxiques.

## Supabase (Environnement)
Dans ce projet, l'`url` et `anonKey` ont été partagées directement via paramétrage de dur. Par la suite, pour le déploiement multi-cibles, elles seront abstraites via `--dart-define` ou un fichier `.env`. Pour l'instant, l'accès local et distant (build mobile) de dev partage le même canal Supabase injecté dans `main.dart`.
