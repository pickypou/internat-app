# 03 - Project Structure

L'arborescence de `lib/` respecte l'architecture **FSD + Clean Architecture** par feature.

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   └── routing/                        # GoRouter global (app_router.dart)
    ├── core/
    │   └── di/                             # GetIt + Injectable (injection.dart, injection.config.dart)
    ├── features/
    │   ├── admin/
    │   │   ├── admin_module.dart            # Router configuration pour `/admin`
    │   │   └── presentation/pages/         # AdminPage (import, calendrier, clôtures)
    │   ├── home/
    │   │   └── presentation/pages/         # HomePage (AppBar + grille de groupes, navigation onglets)
    │   ├── group_selection/
    │   │   ├── group_selection_module.dart  # Router `/lycee` et `/pole-sup`
    │   │   ├── domain/
    │   │   │   ├── entities/               # GroupEntity
    │   │   │   ├── repositories/           # GroupRepository (interface)
    │   │   │   └── usecases/               # GetGroups, CreateGroup, DeleteGroup, RenameGroup,
    │   │   │                               #   GlobalImportUseCase
    │   │   ├── data/
    │   │   │   ├── models/                 # GroupModel
    │   │   │   ├── datasources/            # GroupRemoteDataSourceImpl (Supabase)
    │   │   │   └── repositories/           # GroupRepositoryImpl
    │   │   └── presentation/
    │   │       ├── bloc/                   # GroupBloc / GroupEvent / GroupState
    │   │       ├── pages/                  # LyceePage, PoleSupPage
    │   │       └── widgets/                # GroupSelectionView, CreateGroupForm,
    │   │                                   #   GlobalImportSheet
    │   ├── students/
    │   │   ├── domain/
    │   │   │   ├── entities/               # StudentEntity
    │   │   │   ├── repositories/           # StudentRepository (interface)
    │   │   │   └── usecases/               # GetStudents, GetAllStudents, AddStudent,
    │   │   │                               #   AddStudents, UpdateStudent, DeleteStudent,
    │   │   │                               #   DeleteStudentsByGroup
    │   │   ├── data/
    │   │   │   ├── models/                 # StudentModel
    │   │   │   ├── datasources/            # StudentRemoteDataSourceImpl (upsert [Nom+Prénom+Classe])
    │   │   │   └── repositories/           # StudentRepositoryImpl
    │   │   └── presentation/
    │   │       ├── bloc/                   # StudentBloc / StudentEvent / StudentState
    │   │       └── widgets/                # AddStudentForm, BulkImportStudentsSheet
    │   ├── attendance/
    │   │   ├── domain/
    │   │   │   ├── entities/               # AttendanceEntity
    │   │   │   ├── repositories/           # AttendanceRepository (interface)
    │   │   │   └── usecases/               # GetAttendances, SaveAttendance, DeleteAttendance
    │   │   ├── data/
    │   │   │   ├── models/                 # AttendanceModel
    │   │   │   ├── datasources/            # AttendanceRemoteDataSourceImpl
    │   │   │   │                           #   (gestion UUID virtuel appel-dimanche)
    │   │   │   └── repositories/           # AttendanceRepositoryImpl
    │   │   └── presentation/
    │   │       ├── bloc/                   # AttendanceBloc / AttendanceEvent / AttendanceState
    │   │       ├── pages/                  # AttendanceTablePage
    │   │       └── widgets/                # AttendanceTableWidget, StatusModal,
    │   │                                   #   SegmentedProgressBar
    │   ├── stages/
    │   │   ├── domain/
    │   │   │   ├── entities/               # StagePeriodEntity (className, type, startDate, endDate)
    │   │   │   ├── repositories/           # StagePeriodRepository (interface)
    │   │   │   ├── services/               # StagePeriodService (logique pure : classStatusOn,
    │   │   │   │                           #   isInStage, filterActiveStudents)
    │   │   │   └── usecases/               # GetStagePeriodsUseCase, CalendarImportUseCase
    │   │   ├── data/
    │   │   │   ├── datasources/            # StagePeriodRemoteDataSource (Supabase)
    │   │   │   └── repositories/           # StagePeriodRepositoryImpl
    │   │   └── presentation/
    │   │       └── widgets/                # CalendarImportSheet (import TSV : Classe|Type|Début|Fin)
    │   └── archives/
    │       ├── archives_module.dart         # Router `/archives`
    │       ├── data/
    │       │   ├── models/                 # AttendanceHistoryReport
    │       │   └── datasources/            # ArchivesRemoteDataSource (fetch depuis attendance_history)
    │       └── presentation/
    │           ├── pages/                  # ArchivesPage (liste, recherche, badge LYCÉE/POL-SUP)
    │           └── widgets/                # ReportDetailsSheet (détail d'un rapport)
    └── shared/
        ├── error/                          # Failure classes
        ├── theme/                          # AppTheme, AppColors, ThemeExt, GroupTheme
        ├── utils/                          # Utilitaires génériques
        └── widgets/                        # CustomCard, ImportPasteField (onTap + onLongPress)
```

### Règles d'Intégration
- Chaque feature possède ses propres `domain/`, `data/`, `presentation/`.
- Les Blocs sont injectés via `getIt<XBloc>()` — jamais instanciés manuellement.
- Les widgets génériques (utilisés dans ≥ 2 features) vont dans `shared/widgets/`.
- Groupes virtuels (`appel-dimanche`) : jamais stockés comme UUID en DB, toujours gérés par logique applicative.
- `StagePeriodService` est un service de domaine pur (no Flutter, no Supabase) — entièrement testable en unitaire.
