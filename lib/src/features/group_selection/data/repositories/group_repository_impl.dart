import 'package:injectable/injectable.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';

/// Implementation of [GroupRepository] mapping data source to domain.
@Injectable(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;

  GroupRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<GroupEntity>> getGroups() async {
    // Models returned from remote data source are automatically cast
    // to their parent GroupEntity up the chain.
    return await _remoteDataSource.getGroups();
  }

  @override
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false}) async {
    return await _remoteDataSource.createGroup(name, colorHex, isPoleSup: isPoleSup);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    return await _remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<void> renameGroup(String groupId, String newName) async {
    return await _remoteDataSource.renameGroup(groupId, newName);
  }

  @override
  Future<String?> getGroupIdByName(String name) async {
    return await _remoteDataSource.getGroupIdByName(name);
  }

  @override
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false}) async {
    return await _remoteDataSource.ensureGroupExists(name, colorHex, isPoleSup: isPoleSup);
  }
}
