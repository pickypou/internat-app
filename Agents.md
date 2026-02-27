Agents.md - Règles du Projet InternatApp
1. Architecture & Structure (FSD + Clean Arch)
L'application doit suivre strictement le découpage Feature-Sliced Design.

Layers :

app : Configuration globale (bloc_observer, theme, routing).

processes : (Optionnel) Logique complexe inter-features.

pages : Composition des features pour former des écrans.

features : Logique métier concrète (ex: attendance_flow, group_selection).

entities : Modèles de données métier et logique de base (ex: Student, Attendance).

shared : Composants réutilisables, clients API (Supabase), utils.

2. State Management (Bloc Pattern)
Utiliser uniquement la librairie flutter_bloc.

Séparer strictement les Events, les States et le Bloc.

Chaque feature doit avoir son dossier bloc/.

Les états doivent être immuables (utiliser equatable).

3. Data Source (Supabase)
Utiliser supabase_flutter.

Toutes les interactions avec la base de données passent par un Repository situé dans la couche features ou entities.

Pas d'appels directs à Supabase dans les fichiers UI.

4. Règles de Code (Dart & Flutter)
Utiliser des constructeurs const autant que possible.

Favoriser la composition plutôt que l'héritage.

Respecter le principe de responsabilité unique (SRP).

Langue du code (variables, fonctions) : Anglais.

Langue de l'interface : Français.

Abstraction des Widgets (DRY) : > - Tout widget UI (Card, Button, Input, ListTile, etc.) utilisé plus de deux fois doit être extrait dans src/shared/widgets/.

Nommage : Utiliser le préfixe Custom (ex: CustomCard, CustomButton).

Ces widgets doivent être hautement paramétrables (couleurs, fonctions de callback, icônes) pour s'adapter aux différents contextes des features.

5. Gestion des Erreurs
Ne jamais laisser un catch vide.

Transformer les erreurs Supabase en Failures explicites pour les remonter au Bloc.