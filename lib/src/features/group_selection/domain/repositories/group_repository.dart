import '../entities/group_entity.dart';

/// Abstract interface for group data operations.
/// Defines the contract for the domain layer.
abstract class GroupRepository {
  /// Retrieves the list of groups.
  Future<List<GroupEntity>> getGroups();

  /// Creates a new group.
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false});
  Future<void> deleteGroup(String groupId);
  Future<void> renameGroup(String groupId, String newName);
  Future<String?> getGroupIdByName(String name);
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false});
}
