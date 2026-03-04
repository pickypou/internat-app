import 'dart:developer' as dev;
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
  Future<void> deleteAllStudents();
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
  Future<void> deleteAllStudents() async {
    try {
      // Supabase trick to delete all rows: neq uuid a non-existing uuid,
      // or filtering for id is not null.
      await _supabaseClient
          .from('students')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw ServerFailure('Failed to delete all students: $e');
    }
  }

  @override
  Future<void> addStudents(List<StudentEntity> students) async {
    try {
      if (students.isEmpty) return;

      // Fetch ALL students globally (not just a single group) to allow
      // multi-group batch import and key by [lastName|firstName|className].
      final existingResponse = await _supabaseClient
          .from('students')
          .select('id, first_name, last_name, class_name');

      // Build lookup map: "lastname|firstname|classname" -> existing student id
      final existingMap = <String, String>{};
      for (final doc in existingResponse as List<dynamic>) {
        final l = (doc['last_name'] as String? ?? '').toLowerCase().trim();
        final f = (doc['first_name'] as String? ?? '').toLowerCase().trim();
        final c = (doc['class_name'] as String? ?? '').toLowerCase().trim();
        existingMap['$l|$f|$c'] = doc['id'] as String;
      }

      final List<Map<String, dynamic>> toInsert = [];

      for (final student in students) {
        final l = student.lastName.toLowerCase().trim();
        final f = student.firstName.toLowerCase().trim();
        final c = student.className.toLowerCase().trim();
        final key = '$l|$f|$c';

        if (existingMap.containsKey(key)) {
          // Update: refresh room_number (may have changed) + group_id
          final existingId = existingMap[key]!;
          dev.log('[addStudents] UPDATE student id=$existingId ($l $f $c)');
          await _supabaseClient
              .from('students')
              .update({
                'room_number': student.roomNumber,
                'group_id': student.groupId,
              })
              .eq('id', existingId);
        } else {
          // Insert new student
          dev.log('[addStudents] INSERT new student ($l $f $c)');
          toInsert.add({
            'first_name': student.firstName,
            'last_name': student.lastName,
            'room_number': student.roomNumber,
            'class_name': student.className,
            'group_id': student.groupId,
          });
        }
      }

      if (toInsert.isNotEmpty) {
        dev.log(
          '[addStudents] Batch inserting ${toInsert.length} new students',
        );
        await _supabaseClient.from('students').insert(toInsert);
      }
    } catch (e, stack) {
      dev.log('[addStudents] ERROR: $e\n$stack');
      throw ServerFailure(
        'Failed to bulk insert/update students in Supabase: $e',
      );
    }
  }
}
