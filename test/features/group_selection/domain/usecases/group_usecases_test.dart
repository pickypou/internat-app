import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/group_selection/domain/entities/group_entity.dart';
import 'package:internat_app/src/features/group_selection/domain/repositories/group_repository.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/get_groups_usecase.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/create_group_usecase.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/delete_group_usecase.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/rename_group_usecase.dart';

// ── Manual stub ───────────────────────────────────────────────────────────────
class _FakeGroupRepository implements GroupRepository {
  List<GroupEntity> groups = [
    const GroupEntity(id: 'g1', name: 'Hugue', color: 'E53935'),
    const GroupEntity(id: 'g2', name: 'Cassandra', color: '1E88E5'),
  ];

  String? lastCreatedName;
  String? lastCreatedColor;
  String? lastDeletedId;
  String? lastRenamedId;
  String? lastRenamedName;

  @override
  Future<List<GroupEntity>> getGroups() async => List.from(groups);

  @override
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false}) async {
    lastCreatedName = name;
    lastCreatedColor = colorHex;
    groups.add(
      GroupEntity(id: 'new-${groups.length}', name: name, color: colorHex, isPoleSup: isPoleSup),
    );
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    lastDeletedId = groupId;
    groups.removeWhere((g) => g.id == groupId);
  }

  @override
  Future<void> renameGroup(String groupId, String newName) async {
    lastRenamedId = groupId;
    lastRenamedName = newName;
  }

  @override
  Future<String?> getGroupIdByName(String name) async {
    return groups
        .where((g) => g.name.toLowerCase() == name.toLowerCase())
        .map((g) => g.id)
        .firstOrNull;
  }

  @override
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false}) async {
    final found = await getGroupIdByName(name);
    if (found != null) return found;
    await createGroup(name, colorHex, isPoleSup: isPoleSup);
    return groups.last.id;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late _FakeGroupRepository repo;

  setUp(() {
    repo = _FakeGroupRepository();
  });

  group('GetGroupsUseCase', () {
    test('returns list of groups from repository', () async {
      final useCase = GetGroupsUseCase(repo);
      final result = await useCase();
      expect(result.length, equals(2));
      expect(result.first.name, equals('Hugue'));
    });

    test('returns empty list when no groups exist', () async {
      repo.groups.clear();
      final useCase = GetGroupsUseCase(repo);
      final result = await useCase();
      expect(result, isEmpty);
    });
  });

  group('CreateGroupUseCase', () {
    test('creates a group with given name and color', () async {
      final useCase = CreateGroupUseCase(repo);
      await useCase('NewGroup', 'FF0000');
      expect(repo.lastCreatedName, equals('NewGroup'));
      expect(repo.lastCreatedColor, equals('FF0000'));
      expect(repo.groups.length, equals(3));
    });
  });

  group('DeleteGroupUseCase', () {
    test('deletes the group with matching id', () async {
      final useCase = DeleteGroupUseCase(repo);
      await useCase('g1');
      expect(repo.lastDeletedId, equals('g1'));
      expect(repo.groups.any((g) => g.id == 'g1'), isFalse);
    });

    test('does not affect other groups', () async {
      final useCase = DeleteGroupUseCase(repo);
      await useCase('g1');
      expect(repo.groups.any((g) => g.id == 'g2'), isTrue);
    });
  });

  group('RenameGroupUseCase', () {
    test('calls renameGroup on repository with correct args', () async {
      final useCase = RenameGroupUseCase(repo);
      await useCase('g1', 'Nouveau Nom');
      expect(repo.lastRenamedId, equals('g1'));
      expect(repo.lastRenamedName, equals('Nouveau Nom'));
    });
  });

  group('GroupRepository.getGroupIdByName', () {
    test('finds group id by name (case-insensitive)', () async {
      final id = await repo.getGroupIdByName('hugue');
      expect(id, equals('g1'));
    });

    test('returns null when group does not exist', () async {
      final id = await repo.getGroupIdByName('unknown');
      expect(id, isNull);
    });
  });

  group('GroupRepository.ensureGroupExists', () {
    test('returns existing id when group already exists', () async {
      final id = await repo.ensureGroupExists('Hugue', 'FF0000');
      expect(id, equals('g1'));
      expect(repo.groups.length, equals(2)); // no new group created
    });

    test('creates new group when it does not exist', () async {
      final id = await repo.ensureGroupExists('NewGroup', 'FFFFFF');
      expect(id, isNotNull);
      expect(repo.groups.length, equals(3));
    });
  });
}
