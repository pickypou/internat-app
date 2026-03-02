# 01 - Functional Overview

Application Flutter de gestion de l'internat : pointage, groupes, élèves.

## Fonctionnalités Implémentées

### 1. Gestion des Groupes
- Affichage des groupes sous forme de grille (cards colorées) sur la HomePage.
- **Création** d'un groupe avec nom + couleur personnalisée (FAB → bottom sheet).
- **Renommage** et **suppression** d'un groupe via appui long sur la carte.
- Le groupe **"Appel Dimanche"** est un groupe virtuel (protégé) : il agrège automatiquement tous les élèves hors pol-sup.
- Le groupe **pol-sup** est protégé : il ne peut pas être supprimé.

### 2. Gestion des Élèves
- Affichage de la liste des élèves d'un groupe dans le tableau d'appel (triés A-Z).
- **Ajout individuel** via floating action button (formulaire bottom sheet).
- **Import massif** depuis un tableau Excel collé (onglet ou point-virgule) :
  - Colonnes attendues : `Nom | Prénom | Classe | Chambre | Groupe`
  - Insensible à la casse sur le nom du groupe (`Hugue` = `hugue` = `HUGUE`)
  - Upsert intelligent : clé unique `[Nom + Prénom + Classe]` → update chambre si existant, sinon insert
  - Création automatique du groupe si inconnu (couleur vive aléatoire)
- **Suppression individuelle** via l'icône 🗑 dans la modale de note.
- **Vider un groupe** (tous ses élèves) via menu AppBar ⋮ → « Vider les élèves ».

### 3. Tableau de Pointage (Attendance)
- Navigation vers un groupe → tableau avec une ligne par élève.
- Colonnes : **Classe**, **Chambre**, **Présence soir** (✓/✗), **Bus** (✓/✗), **Note**.
- Tap sur une cellule de statut → cycle Absent/Présent/Bus.
- Tap sur la colonne **Note** → dialog pour saisir/modifier une note sur l'élève du jour.
- Le groupe "Appel Dimanche" interroge les élèves par `student_id list` (jamais par UUID virtuel).
- **Sélection de date** via icône calendrier dans l'AppBar.

### 4. Import Global (HomePage AppBar)
- Icône 📤 dans l'AppBar de la HomePage.
- Coller un tableau multi-groupes → dispatch automatique vers les bons groupes.
- Feedback immédiat : SnackBar vert (succès) ou rouge (erreur) après fermeture de la modale.
- Résumé : "10 élèves importés, 2 lignes ignorées".

## Parcours Utilisateur Typique

```
HomePage → grille des groupes
    ├── Appui long  → Renommer / Supprimer le groupe
    ├── Icône 📤    → Import global multi-groupes
    ├── FAB         → Créer un nouveau groupe
    └── Tap carte   → AttendanceTablePage
                          ├── Colonnes de statut → tap pour changer
                          ├── Colonne Note       → dialog + suppression élève
                          ├── FAB                → Ajouter un élève
                          ├── Icône ☁️           → Import Excel (groupe courant)
                          └── Menu ⋮             → Vider les élèves
```
