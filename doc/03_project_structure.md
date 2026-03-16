# 03 - Project Structure

L'arborescence de `lib/` respecte l'architecture **FSD + Clean Architecture** par feature.

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   └── routing/                   # GoRouter global (app_router.dart)
    ├── core/
    │   └── di/                        # GetIt + Injectable (injection.dart, injection.config.dart)
    ├── features/
    │   ├── admin/
    │   │   ├── admin_module.dart      # Router configuration pour `/admin`
    │   │   └── presentation/pages/    # AdminPage (Boutons d'import, clôture, etc.)
    │   ├── home/
    │   │   └── presentation/pages/    # HomePage (AppBar + grille de groupes)
    │   │   ├── domain/
    │   │   │   ├── entities/          # GroupEntity
    │   │   │   ├── repositories/      # GroupRepository (interface)
    │   │   │   └── usecases/          # GetGroups, CreateGroup, DeleteGroup, RenameGroup,
    │   │   │                          #   GlobalImportUseCase
    │   │   ├── data/
    │   │   │   ├── models/            # GroupModel
    │   │   │   ├── datasources/       # GroupRemoteDataSourceImpl (Supabase)
    │   │   │   └── repositories/      # GroupRepositoryImpl
    │   │   └── presentation/
    │   │       ├── bloc/              # GroupBloc / GroupEvent / GroupState
    │   │       └── widgets/           # GroupSelectionView, CreateGroupForm,
    │   │                              #   GlobalImportSheet
    │   ├── students/
    │   │   ├── domain/
    │   │   │   ├── entities/          # StudentEntity
    │   │   │   ├── repositories/      # StudentRepository (interface)
    │   │   │   └── usecases/          # GetStudents, GetAllStudents, AddStudent,
    │   │   │                          #   AddStudents, UpdateStudent, DeleteStudent,
    │   │   │                          #   DeleteStudentsByGroup
    │   │   ├── data/
    │   │   │   ├── models/            # StudentModel
    │   │   │   ├── datasources/       # StudentRemoteDataSourceImpl (upsert [Nom+Prénom+Classe])
    │   │   │   └── repositories/      # StudentRepositoryImpl
    │   │   └── presentation/
    │   │       ├── bloc/              # StudentBloc / StudentEvent / StudentState
    │   │       └── widgets/           # AddStudentForm, BulkImportStudentsSheet
    │   └── attendance/
    │       ├── domain/
    │       │   ├── entities/          # AttendanceEntity
    │       │   ├── repositories/      # AttendanceRepository (interface)
    │       │   └── usecases/          # GetAttendances, SaveAttendance, DeleteAttendance
    │       ├── data/
    │       │   ├── models/            # AttendanceModel
    │       │   ├── datasources/       # AttendanceRemoteDataSourceImpl
    │       │   │                      #   (gestion UUID virtuel appel-dimanche)
    │       │   └── repositories/      # AttendanceRepositoryImpl
    │       └── presentation/
    │           ├── bloc/              # AttendanceBloc / AttendanceEvent / AttendanceState
    │           ├── pages/             # AttendanceTablePage
    │           └── widgets/           # StatusModal
    └── shared/
        ├── error/                     # Failure classes
        ├── theme/                     # ThemeData, ThemeExt
        └── widgets/                   # CustomCard (onTap + onLongPress)
```

### Règles d'Intégration
- Chaque feature possède ses propres `domain/`, `data/`, `presentation/`.
- Les Blocs sont injectés via `getIt<XBloc>()` — jamais instanciés manuellement.
- Les widgets génériques (utilisés dans ≥ 2 features) vont dans `shared/widgets/`.
- Groupes virtuels (`appel-dimanche`) : jamais stockés comme UUID en DB, toujours gérés par logique applicative.
