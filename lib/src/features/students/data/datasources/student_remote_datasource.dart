import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/student_model.dart';
import '../../domain/entities/student_entity.dart';

/// Abstract interface for student data source.
abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getStudents(String groupId);
  Future<List<StudentModel>> getAllStudentsExcludingGroup(
    String excludedGroupName,
  );
  Future<void> addStudent(StudentEntity student);
  Future<void> updateStudent(StudentEntity student);
  Future<void> deleteStudent(String studentId);
  Future<void> deleteAllStudentsByGroupId(String groupId);
  Future<void> addStudents(List<StudentEntity> students);
}

/// Supabase implementation of the data source.
@Injectable(as: StudentRemoteDataSource)
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final SupabaseClient _supabaseClient;

  StudentRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<List<StudentModel>> getStudents(String groupId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select()
          .eq('group_id', groupId)
          .order('last_name')
          .order('first_name');

      return (response as List<dynamic>)
          .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch students from Supabase: $e');
    }
  }

  @override
  Future<List<StudentModel>> getAllStudentsExcludingGroup(
    String excludedGroupName,
  ) async {
    try {
      // Step 1: fetch all groups to identify the excluded one(s)
      final groupsResponse = await _supabaseClient
          .from('groups')
          .select('id, name');

      final excludedGroupIds = (groupsResponse as List<dynamic>)
          .where(
            (g) =>
                (g['name'] as String).toLowerCase().trim() ==
                excludedGroupName.toLowerCase().trim(),
          )
          .map((g) => g['id'] as String)
          .toSet();

      // Step 2: fetch ALL students then filter client-side
      final response = await _supabaseClient
          .from('students')
          .select()
          .order('last_name')
          .order('first_name');

      return (response as List<dynamic>)
          .where((json) => !excludedGroupIds.contains(json['group_id']))
          .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch all students from Supabase: $e');
    }
  }

  @override
  Future<void> addStudent(StudentEntity student) async {
    try {
      // Create a model just to use the toJson method easily
      final model = StudentModel(
        id: student.id,
        firstName: student.firstName,
        lastName: student.lastName,
        roomNumber: student.roomNumber,
        className: student.className,
        groupId: student.groupId,
      );

      await _supabaseClient.from('students').insert(model.toJson());
    } catch (e) {
      throw ServerFailure('Failed to create student in Supabase: $e');
    }
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    try {
      final model = StudentModel(
        id: student.id,
        firstName: student.firstName,
        lastName: student.lastName,
        roomNumber: student.roomNumber,
        className: student.className,
        groupId: student.groupId,
      );

      await _supabaseClient
          .from('students')
          .update(model.toJson())
          .eq('id', student.id);
    } catch (e) {
      throw ServerFailure('Failed to update student in Supabase: $e');
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    try {
      await _supabaseClient.from('students').delete().eq('id', studentId);
    } catch (e) {
      throw ServerFailure('Failed to delete student from Supabase: $e');
    }
  }

  @override
  Future<void> deleteAllStudentsByGroupId(String groupId) async {
    try {
      await _supabaseClient.from('students').delete().eq('group_id', groupId);
    } catch (e) {
      throw ServerFailure('Failed to delete students for group: $e');
    }
  }

  @override
  Future<void> addStudents(List<StudentEntity> students) async {
    try {
      if (students.isEmpty) return;
      final groupId = students.first.groupId;

      // Fetch existing to avoid duplicates based on firstName + lastName
      final existingResponse = await _supabaseClient
          .from('students')
          .select('id, first_name, last_name')
          .eq('group_id', groupId);

      final List<dynamic> existingDocs = existingResponse;
      final existingMap =
          <String, String>{}; // key: "first_name|last_name", value: id
      for (var doc in existingDocs) {
        final f = (doc['first_name'] as String).toLowerCase().trim();
        final l = (doc['last_name'] as String).toLowerCase().trim();
        existingMap['$f|$l'] = doc['id'] as String;
      }

      final List<Map<String, dynamic>> toInsert = [];

      for (var student in students) {
        final key =
            '${student.firstName.toLowerCase().trim()}|${student.lastName.toLowerCase().trim()}';

        if (existingMap.containsKey(key)) {
          // Update existing
          final model = StudentModel(
            id: existingMap[key]!, // Use existing ID
            firstName: student.firstName,
            lastName: student.lastName,
            roomNumber: student.roomNumber,
            className: student.className,
            groupId: student.groupId,
          );
          await _supabaseClient
              .from('students')
              .update(model.toJson())
              .eq('id', existingMap[key]!);
        } else {
          // Insert new
          toInsert.add(
            StudentModel(
              id: student.id,
              firstName: student.firstName,
              lastName: student.lastName,
              roomNumber: student.roomNumber,
              className: student.className,
              groupId: student.groupId,
            ).toJson(),
          );
        }
      }

      if (toInsert.isNotEmpty) {
        await _supabaseClient.from('students').insert(toInsert);
      }
    } catch (e) {
      throw ServerFailure(
        'Failed to bulk insert/update students in Supabase: $e',
      );
    }
  }
}
