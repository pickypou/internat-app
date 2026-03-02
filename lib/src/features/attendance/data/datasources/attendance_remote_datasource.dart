import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/attendance_entity.dart';

/// Virtual group constant — must not be sent as a UUID to Postgres.
const _kAppelDimancheGroupId = 'appel-dimanche';
const _kPolSupGroupName = 'pol-sup';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceModel>> getAttendancesForGroup(
    String groupId,
    DateTime date,
  );
  Future<AttendanceModel> upsertAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);
}

@Injectable(as: AttendanceRemoteDataSource)
class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AttendanceRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns all student IDs that belong to the "appel-dimanche" virtual group
  /// (= all real groups, minus pol-sup).
  Future<List<String>> _getAppelDimancheStudentIds() async {
    // 1. Find the group_id of pol-sup
    final groupsResp = await _supabaseClient.from('groups').select('id, name');
    final polSupIds = (groupsResp as List<dynamic>)
        .where(
          (g) =>
              (g['name'] as String).toLowerCase().trim() == _kPolSupGroupName,
        )
        .map((g) => g['id'] as String)
        .toSet();

    // 2. Fetch all students, exclude pol-sup ones
    final studentsResp = await _supabaseClient
        .from('students')
        .select('id, group_id');
    return (studentsResp as List<dynamic>)
        .where((s) => !polSupIds.contains(s['group_id']))
        .map((s) => s['id'] as String)
        .toList();
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Future<List<AttendanceModel>> getAttendancesForGroup(
    String groupId,
    DateTime date,
  ) async {
    try {
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      if (groupId == _kAppelDimancheGroupId) {
        // Virtual group: query by student_id list instead of group_id UUID
        final studentIds = await _getAppelDimancheStudentIds();
        if (studentIds.isEmpty) return [];

        final response = await _supabaseClient
            .from('attendance')
            .select()
            .inFilter('student_id', studentIds)
            .eq('check_date', dateString);

        return (response as List)
            .map((json) => AttendanceModel.fromJson(json))
            .toList();
      }

      // Normal group: filter by group_id UUID
      final response = await _supabaseClient
          .from('attendance')
          .select()
          .eq('group_id', groupId)
          .eq('check_date', dateString);

      return (response as List)
          .map((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to load attendances: $e');
    }
  }

  @override
  Future<AttendanceModel> upsertAttendance(AttendanceEntity attendance) async {
    try {
      // For the virtual appel-dimanche group, look up the student's real group_id
      // so we never store 'appel-dimanche' as a UUID in the DB.
      String effectiveGroupId = attendance.groupId;
      if (effectiveGroupId == _kAppelDimancheGroupId) {
        final studentResp = await _supabaseClient
            .from('students')
            .select('group_id')
            .eq('id', attendance.studentId)
            .maybeSingle();
        effectiveGroupId =
            (studentResp?['group_id'] as String?) ?? attendance.groupId;
      }

      final model = AttendanceModel(
        id: attendance.id,
        studentId: attendance.studentId,
        checkDate: attendance.checkDate,
        isPresentEvening: attendance.isPresentEvening,
        isInBus: attendance.isInBus,
        note: attendance.note,
        groupId: effectiveGroupId, // always a real UUID
      );

      final response = await _supabaseClient
          .from('attendance')
          .upsert(model.toJson(), onConflict: 'id')
          .select()
          .single();

      return AttendanceModel.fromJson(response);
    } catch (e) {
      throw ServerFailure('Failed to update attendance: $e');
    }
  }

  @override
  Future<void> deleteAttendance(String id) async {
    try {
      await _supabaseClient.from('attendance').delete().eq('id', id);
    } catch (e) {
      throw ServerFailure('Failed to delete attendance: $e');
    }
  }
}
