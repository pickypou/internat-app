import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/group_model.dart';

/// Abstract interface for group data source.
abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false});
  Future<void> deleteGroup(String groupId);
  Future<void> renameGroup(String groupId, String newName);

  /// Returns the group ID matching [name] (case-insensitive), or null if not found.
  Future<String?> getGroupIdByName(String name);

  /// Finds or creates a group by [name] and returns its ID.
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false});
}

/// Supabase implementation of the data source.
@Injectable(as: GroupRemoteDataSource)
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final SupabaseClient _supabaseClient;

  GroupRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _supabaseClient
          .from('groups')
          .select('*, students(count)')
          .order('name');

      return (response as List<dynamic>)
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch groups from Supabase: $e');
    }
  }

  @override
  Future<void> createGroup(String name, String colorHex, {bool isPoleSup = false}) async {
    try {
      await _supabaseClient.from('groups').insert({
        'name': name,
        'color': colorHex,
        'is_pole_sup': isPoleSup,
      });
    } catch (e) {
      throw ServerFailure('Failed to create group in Supabase: $e');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      // Must delete students first (FK constraint: students.group_id → groups.id)
      await _supabaseClient.from('students').delete().eq('group_id', groupId);
      // Then delete the group itself
      await _supabaseClient.from('groups').delete().eq('id', groupId);
    } catch (e) {
      throw ServerFailure('Failed to delete group in Supabase: $e');
    }
  }

  @override
  Future<void> renameGroup(String groupId, String newName) async {
    try {
      await _supabaseClient
          .from('groups')
          .update({'name': newName})
          .eq('id', groupId);
    } catch (e) {
      throw ServerFailure('Failed to rename group in Supabase: $e');
    }
  }

  @override
  Future<String?> getGroupIdByName(String name) async {
    try {
      final response = await _supabaseClient.from('groups').select('id, name');
      final nameKey = name.toLowerCase().trim();
      final found = (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .where((g) => (g['name'] as String).toLowerCase().trim() == nameKey)
          .firstOrNull;
      return found == null ? null : found['id'] as String;
    } catch (e) {
      throw ServerFailure('Failed to find group by name: $e');
    }
  }

  @override
  Future<String> ensureGroupExists(String name, String colorHex, {bool isPoleSup = false}) async {
    final existingId = await getGroupIdByName(name);
    if (existingId != null) return existingId;
    // Create group and return the new ID
    final response = await _supabaseClient
        .from('groups')
        .insert({
          'name': name,
          'color': colorHex,
          'is_pole_sup': isPoleSup,
        })
        .select('id')
        .single();
    return response['id'] as String;
  }
}
