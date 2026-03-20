# 01 - Functional Overview

Application Flutter de gestion de l'internat : pointage, groupes, élèves, stages et archives.

## Fonctionnalités Implémentées

### 1. Gestion des Groupes
- Affichage des groupes sous forme de grille (cards colorées) sur la HomePage.
- **Renommage** et **suppression** d'un groupe via appui long sur la carte.
- Le groupe **\"Appel Dimanche\"** est un groupe virtuel (protégé) : il agrège automatiquement tous les élèves hors pol-sup.
- Le groupe **pol-sup** est protégé : il ne peut pas être supprimé.

### 2. Gestion des Élèves
- Affichage de la liste des élèves d'un groupe dans le tableau d'appel (triés A-Z).
- **Ajout individuel** via floating action button (formulaire bottom sheet).
- **Import massif** depuis un tableau Excel collé (onglet ou point-virgule) :
  - Formats supportés :
    - 5 colonnes : `Nom | Prénom | Classe | Chambre | Groupe`
    - 4 colonnes : `Nom Complet | Classe | Chambre | Groupe` (Découpe auto du prénom après le 1er espace)
    - 2 colonnes : `Nom | Prénom` (uniquement depuis l'intérieur d'un groupe)
  - Insensible à la casse sur le nom du groupe (`Hugue` = `hugue` = `HUGUE`)
  - Upsert intelligent : clé unique `[Nom + Prénom + Classe]` → update chambre si existant, sinon insert
  - Création automatique du groupe si inconnu (couleur vive aléatoire)
- **Suppression individuelle** via l'icône 🗑 dans la modale de note.

### 3. Tableau de Pointage (Attendance)
- Vue **Lycée** (`LyceePage`) : sections expansibles par groupe, tri alphabétique ou par classe au choix.
  - Barre de progression segmentée (`SegmentedProgressBar`) résumant présents/absents/bus par groupe.
  - Filtre "Afficher tout" pour ignorer le filtrage par statut de stage.
- Vue **Pôle-Sup** (`PoleSupPage`) : sections expansibles par **className** (classe de l'élève), indépendamment des groupes.
- Colonnes du tableau : **Classe**, **Chambre**, **Présence soir** (✓/✗), **Bus** (✓/✗), **Note**.
- Tap sur une cellule de statut → cycle Absent/Présent/Bus.
- Tap sur la colonne **Note** → dialog pour saisir/modifier une note sur l'élève du jour.
- **Sélection de date** via icône calendrier dans l'AppBar.
- Les élèves en **stage ou alternance** (voir feature Stages) sont automatiquement filtrés du tableau de pointage pour la date sélectionnée.

### 4. Gestion des Périodes de Stage (Stages)
- Import d'un calendrier de périodes de présence/stage/alternance par classe via bottom sheet (`CalendarImportSheet`).
- Format d'import (colonnes tabulées) : `Classe | Type | Début (JJ/MM/AAAA) | Fin (JJ/MM/AAAA)`
- Types supportés : `PRESENCE`, `STAGE`, `ALTERNANCE`
- Le `StagePeriodService` détermine le statut d'une classe à une date donnée (priorité STAGE/ALTERNANCE > PRESENCE > HORS_QUINZAINE).
- Les élèves dont la classe est `STAGE` ou `ALTERNANCE` à la date choisie sont **masqués** du tableau de pointage (filtrés par `filterActiveStudents`).

### 5. Archives (Historique des Rapports)
- Page dédiée (`ArchivesPage`) accessible depuis la navigation principale.
- Liste des rapports archivés (table `attendance_history`), avec badge **LYCÉE** ou **POL-SUP**.
- **Recherche** en temps réel par nom de rapport, période (`period_label`) ou date.
- Bouton **Détails** : affiche le contenu complet du rapport dans un bottom sheet (`ReportDetailsSheet`).
- Bouton **Voir PDF** : ouvre le PDF généré lors de la clôture dans le navigateur externe.

### 6. Admin Page (Centralisation des actions)
- Bouton d'accès (icône administration) dans l'AppBar de la HomePage.
- **Gestion des données** :
  - **Création d'un groupe** : Permet de créer un nouveau groupe (nom + couleur).
  - **Import Calendrier** : Importer les périodes PRESENCE/STAGE/ALTERNANCE par classe (`CalendarImportSheet`).
  - **Import Global (Excel)** : Coller un tableau multi-groupes → dispatch automatique. Upsert intelligent, création de groupe automatique si inconnu.
  - **Suppression totale** : Vider intégralement la base de données de tous les élèves de l'application.
- **Clôture administrative** (Archivage Légal) :
  - Conservation immuable des présences sur 10 ans. Les informations de l'élève (Nom, Prénom, Chambre, Classe) sont figées en dur.
  - **Lycée** : Clôture de la semaine (tous les groupes sauf Pôle-Sup). Génère le PDF de la semaine et vide le tableau. Label : `LYCÉE : [Dimanche] au [Vendredi]`.
  - **Pôle-Sup** : Clôture de la quinzaine (uniquement Pôle-Sup). Génère le PDF et vide le groupe. Label : `POL-SUP : [Dimanche] au [Vendredi_S+1]`.
  - **PDF Automatique** : Génération formelle pour impression A4. Nom du fichier correspond à la période avec la mention de génération.

## Parcours Utilisateur Typique

```
HomePage → grille des groupes
    ├── Appui long  → Renommer / Supprimer le groupe
    ├── Icône ⚙️    → Navigation vers l'AdminPage
    │                  ├── Créer un groupe
    │                  ├── Import Calendrier (stages)
    │                  ├── Import global multi-groupes
    │                  ├── Suppression totale des élèves
    │                  └── Clôtures (Semaine Lycée / Quinzaine Pol-Sup)
    ├── Onglet Lycée → LyceePage
    │                  ├── Sections expansibles par groupe
    │                  ├── Barre de progression par groupe
    │                  ├── Switch tri alphabétique / par classe
    │                  ├── Filtre "Tout afficher" (stages)
    │                  ├── AttendanceTableWidget par groupe
    │                  │     ├── Colonnes de statut → tap pour changer
    │                  │     └── Colonne Note → dialog + suppression élève
    │                  └── FAB → Ajouter un élève manuellement
    ├── Onglet Pôle-Sup → PoleSupPage
    │                  ├── Sections expansibles par className
    │                  └── AttendanceTableWidget par classe
    └── Onglet Archives → ArchivesPage
                       ├── Recherche en temps réel
                       ├── Détails rapport (bottom sheet)
                       └── Ouvrir PDF
```
