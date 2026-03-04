# 05 - Supabase Backend

Le projet InternatApp repose sur **Supabase** exclusivement (`supabase_flutter`). Firebase n'est pas utilisé.

## Schéma des Tables

| Table | Colonnes principales | Clé unique |
|---|---|---|
| `groups` | `id` (uuid PK), `name`, `color` (hex 6 chars) | PK |
| `students` | `id` (uuid PK), `first_name`, `last_name`, `class_name`, `room_number`, `group_id` (FK→groups) | — |
| `attendance` | `id` (uuid PK), `student_id` (FK→students), `group_id` (FK→groups), `check_date`, `is_present_evening`, `is_in_bus`, `note` | — |
| `attendance_history` | `id` (uuid PK), `student_id`, `group_id`, `stored_last_name`, `stored_first_name`, `period_label`, `check_date`, `status`, `archive_date` | — |

## Contraintes FK

- `students.group_id` → `groups.id` : **sans CASCADE** côté DB. La suppression d'un groupe supprime d'abord les élèves via code applicatif (`GroupRemoteDataSourceImpl.deleteGroup`).
- `attendance.student_id` → `students.id` : gérée côté applicatif.
- L'historique `attendance_history` n'a **aucune contrainte Foreign Key stricte** vers `students` ou `groups` afin de garantir l'immutabilité et la conservation (Boîte Noire) de l'archive même si les données sources sont supprimées des années plus tard.

## Archivage Légal (Boîte Noire)
`attendance_history` est conçu comme une table de log en mode "Append-Only".
- RLS : Autorise `INSERT` et `SELECT` pour les utilisateurs authentifiés.
- RLS : Ne définit *aucune* "Policy" pour `UPDATE` et `DELETE`, ce qui empêche techniquement (et silencieusement) toute altération logicielle de l'historique légal du pointage.
- Les données élèves sont écrites en "copie dure" (texte brut). Une étiquette `period_label` classifie chaque archive pour la récupération.

## Groupes Virtuels

Le groupe **"Appel Dimanche"** (`appel-dimanche`) n'existe **pas** dans la table `groups`. Il est traité côté applicatif :

- **Lecture** : `AttendanceRemoteDataSourceImpl.getAttendancesForGroup` utilise `.inFilter('student_id', studentIds)` au lieu de `.eq('group_id', 'appel-dimanche')` pour éviter l'erreur UUID.
- **Écriture** : `upsertAttendance` résout le vrai `group_id` de l'étudiant avant d'écrire.
- Les élèves **pol-sup** sont exclus de la liste.

## Upsert Élèves (Import)

La méthode `addStudents` implémente un upsert applicatif :

1. Récupère **tous** les élèves en DB (`select id, first_name, last_name, class_name`)
2. Construit une map `lastName|firstName|className → id`
3. Si correspondance → `UPDATE room_number + group_id`
4. Sinon → `INSERT` en batch

## Accès et Configuration

- Initialisé dans `main.dart` via `Supabase.initialize(url, anonKey)`.
- L'instance est injectée via DI : `SupabaseClient` est fourni par `SupabaseModule` dans `injection.dart`.
- Le code UI n'accède **jamais** directement à `SupabaseClient`. Toutes les erreurs Supabase sont converties en `ServerFailure`.

## Variables d'Environnement

```bash
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

Injectées via GitHub Actions Secrets pour CI/CD (voir `doc/09_deployment_and_environment.md`).
