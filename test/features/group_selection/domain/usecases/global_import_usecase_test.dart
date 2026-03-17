import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/group_selection/domain/entities/group_entity.dart';
import 'package:internat_app/src/features/group_selection/domain/repositories/group_repository.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/global_import_usecase.dart';
import 'package:internat_app/src/features/students/data/datasources/student_remote_datasource.dart';
import 'package:internat_app/src/features/students/data/models/student_model.dart';
import 'package:internat_app/src/features/students/domain/entities/student_entity.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────
class _FakeGroupRepo implements GroupRepository {
  final List<GroupEntity> groups = [
    const GroupEntity(id: 'g1', name: 'Hugue', color: 'E53935'),
  ];
  String? lastEnsuredName;

  @override
  Future<List<GroupEntity>> getGroups() async => List.from(groups);

  @override
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false}) async => groups.add(
    GroupEntity(id: 'new-${groups.length}', name: name, color: colorHex, isPoleSup: isPoleSup),
  );

  @override
  Future<void> deleteGroup(String groupId) async {}

  @override
  Future<void> renameGroup(String groupId, String newName) async {}

  @override
  Future<String?> getGroupIdByName(String name) async => groups
      .where((g) => g.name.toLowerCase() == name.toLowerCase())
      .map((g) => g.id)
      .firstOrNull;

  @override
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false}) async {
    lastEnsuredName = name;
    final found = await getGroupIdByName(name);
    if (found != null) return found;
    await createGroup(name, colorHex, isPoleSup: isPoleSup);
    return groups.last.id;
  }
}

class _FakeStudentDataSource implements StudentRemoteDataSource {
  final List<StudentEntity> added = [];

  @override
  Future<void> addStudents(List<StudentEntity> students) async =>
      added.addAll(students);

  @override
  Future<List<StudentModel>> getStudents(String groupId) async => [];

  @override
  Future<List<StudentModel>> getAllStudentsExcludingGroup(
    String excludedGroupName,
  ) async => [];

  @override
  Future<void> addStudent(StudentEntity student) async {}

  @override
  Future<void> updateStudent(StudentEntity student) async {}

  @override
  Future<void> deleteStudent(String studentId) async {}

  @override
  Future<void> deleteAllStudentsByGroupId(String groupId) async {
    added.removeWhere((s) => s.groupId == groupId);
  }

  @override
  Future<void> deleteAllStudents() async {
    added.clear();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late _FakeGroupRepo groupRepo;
  late _FakeStudentDataSource dataSource;
  late GlobalImportUseCase useCase;

  setUp(() {
    groupRepo = _FakeGroupRepo();
    dataSource = _FakeStudentDataSource();
    useCase = GlobalImportUseCase(groupRepo, dataSource);
  });

  test('imports tab-separated students into existing group', () async {
    const raw = 'DUPONT\tJean\t3A\t12\tHugue\nMARTIN\tLucie\t2B\t5\tHugue';
    final result = await useCase(raw);
    expect(result.imported, equals(2));
    expect(result.skipped, equals(0));
    expect(dataSource.added.length, equals(2));
    expect(dataSource.added.every((s) => s.groupId == 'g1'), isTrue);
  });

  test('imports semicolon-separated students', () async {
    const raw = 'DUPONT;Jean;3A;12;Hugue\nMARTIN;Lucie;2B;5;Hugue';
    final result = await useCase(raw);
    expect(result.imported, equals(2));
    expect(dataSource.added.length, equals(2));
  });

  test('normalizes group name casing (hugue → Hugue)', () async {
    const raw = 'DUPONT\tJean\t3A\t12\thugue';
    final result = await useCase(raw);
    expect(result.imported, equals(1));
    // Group 'hugue' normalized to 'Hugue' → maps to existing g1
    expect(dataSource.added.first.groupId, equals('g1'));
  });

  test('creates new group when it does not exist', () async {
    const raw = 'BON\tPaul\t1B\t8\tNouveau';
    final result = await useCase(raw);
    expect(result.imported, equals(1));
    expect(groupRepo.lastEnsuredName, equals('Nouveau'));
    expect(groupRepo.groups.length, equals(2));
  });

  test('returns 0 imported for empty input', () async {
    final result = await useCase('');
    expect(result.imported, equals(0));
    expect(result.skipped, equals(0));
  });

  test('skips lines with missing Nom or Prénom', () async {
    const raw = '\tJean\t3A\t12\tHugue'; // empty lastName
    final result = await useCase(raw);
    expect(result.skipped, equals(1));
    expect(result.imported, equals(0));
  });

  test('skips lines with missing Groupe column', () async {
    const raw = 'DUPONT\tJean\t3A\t12'; // only 4 columns
    final result = await useCase(raw);
    expect(result.skipped, equals(1));
    expect(result.imported, equals(0));
  });

  test('imports valid lines and skips invalid ones in same input', () async {
    const raw = 'DUPONT\tJean\t3A\t12\tHugue\n\t\t\t\t'; // 1 valid + 1 blank
    final result = await useCase(raw);
    expect(result.imported, equals(1));
    // blank line is skipped (trimmed to empty → filtered by where)
  });
}
