import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/group_model.dart';

/// Abstract interface for group data source.
abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<void> createGroup(String name, String colorHex);
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
          .select()
          .order('name');

      return (response as List<dynamic>)
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch groups from Supabase: $e');
    }
  }

  @override
  Future<void> createGroup(String name, String colorHex) async {
    try {
      await _supabaseClient.from('groups').insert({
        'name': name,
        'color': colorHex,
      });
    } catch (e) {
      throw ServerFailure('Failed to create group in Supabase: $e');
    }
  }
}
