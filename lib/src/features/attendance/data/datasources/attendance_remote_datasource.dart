import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/attendance_model.dart';
import '../models/attendance_archive_model.dart';
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

  /// Archives attendances for all groups EXCEPT "pol-sup" and then deletes them.
  /// Returns the archived records so a PDF can be generated.
  Future<List<AttendanceArchiveModel>> archiveAndResetLycee(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );

  /// Archives attendances ONLY for the "pol-sup" group and then deletes them.
  /// Returns the archived records so a PDF can be generated.
  Future<List<AttendanceArchiveModel>> archiveAndResetPolSup(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );
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

  @override
  Future<List<AttendanceArchiveModel>> archiveAndResetLycee(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _archiveAndReset(
      startDate,
      endDate,
      periodLabel,
      excludePolSup: true,
    );
  }

  @override
  Future<List<AttendanceArchiveModel>> archiveAndResetPolSup(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _archiveAndReset(
      startDate,
      endDate,
      periodLabel,
      excludePolSup: false,
    );
  }

  Future<List<AttendanceArchiveModel>> _archiveAndReset(
    DateTime startDate,
    DateTime endDate,
    String periodLabel, {
    required bool excludePolSup,
  }) async {
    try {
      final startStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      // 1. Resolve pol-sup group id
      final groupsResp = await _supabaseClient
          .from('groups')
          .select('id, name');
      final polSupIds = (groupsResp as List<dynamic>)
          .where(
            (g) =>
                (g['name'] as String).toLowerCase().trim() == _kPolSupGroupName,
          )
          .map((g) => g['id'] as String)
          .toSet();

      // 2. Fetch all raw attendances in range
      final attendanceResp = await _supabaseClient
          .from('attendance')
          .select()
          .gte('check_date', startStr)
          .lte('check_date', endStr);

      final List<dynamic> allAttendances = attendanceResp as List<dynamic>;
      if (allAttendances.isEmpty) return []; // Nothing to archive

      // 3. Filter attendances based on pol-sup rules
      final targetAttendances = allAttendances.where((att) {
        final gId = att['group_id'] as String;
        // If excludePolSup is true, we want everything EXCEPT pol-sup.
        // If excludePolSup is false, we want ONLY pol-sup.
        return excludePolSup
            ? !polSupIds.contains(gId)
            : polSupIds.contains(gId);
      }).toList();

      if (targetAttendances.isEmpty) return [];

      // 4. Fetch students for hardcopies
      final targetStudentIds = targetAttendances
          .map((a) => a['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (targetStudentIds.isEmpty) return [];

      final studentsResp = await _supabaseClient
          .from('students')
          .select('id, last_name, first_name, class_name, room_number')
          .inFilter('id', targetStudentIds);

      final studentMap = {
        for (final s in (studentsResp as List<dynamic>)) s['id'] as String: s,
      };

      // 5. Build archive models
      final archives = <Map<String, dynamic>>[];
      final attendanceIdsToDelete = <String>[];

      for (final att in targetAttendances) {
        final sId = att['student_id'] as String?;
        if (sId == null) continue; // shouldn't happen but safe
        final student = studentMap[sId];
        if (student == null) continue;

        attendanceIdsToDelete.add(att['id'] as String);

        // Compute status exactly like computedStatus
        final isPresentEvening = att['is_present_evening'] as bool;
        // Note: Stage logic normally happens in UI, but the archive is a snapshot.
        // We will default to Présent/Absent for the raw data snapshot.
        // Or if the app requires actual computed status, we could compute it
        // with StagePeriodService, but for the archive history we store simple status.
        String status = isPresentEvening ? 'Présent' : 'Absent';

        archives.add({
          'id': _generateUuidV4(),
          'student_id': sId,
          'group_id': att['group_id'],
          'stored_last_name': student['last_name'] ?? '',
          'stored_first_name': student['first_name'] ?? '',
          'stored_class_name': student['class_name'] ?? '',
          'stored_room_number': student['room_number'] ?? '',
          'check_date': att['check_date'],
          'status': status,
          'note': att['note'],
          'period_label': periodLabel,
        });
      }

      if (archives.isNotEmpty) {
        // 6. Insert into attendance_history
        await _supabaseClient.from('attendance_history').insert(archives);

        // 7. Delete from original attendance table
        // Supabase limits .inFilter to a certain amount,
        // chunking by 100 just in case.
        for (var i = 0; i < attendanceIdsToDelete.length; i += 100) {
          final chunk = attendanceIdsToDelete.skip(i).take(100).toList();
          await _supabaseClient
              .from('attendance')
              .delete()
              .inFilter('id', chunk);
        }

        // Return the models for PDF generation
        return archives.map((json) {
          // Add dummy ID and archiveDate since Supreme gives it to us on insert, we just need it for the UI/PDF right now.
          json['id'] = '';
          json['archive_date'] = DateTime.now().toIso8601String();
          return AttendanceArchiveModel.fromJson(json);
        }).toList();
      }
      return [];
    } catch (e) {
      throw ServerFailure('Failed to archive and reset: $e');
    }
  }

  String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    // Set UUID version to 4
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    // Set variant to RFC4122
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    String hex(List<int> bytes) {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    }

    return '${hex(bytes.sublist(0, 4))}-${hex(bytes.sublist(4, 6))}-${hex(bytes.sublist(6, 8))}-${hex(bytes.sublist(8, 10))}-${hex(bytes.sublist(10, 16))}';
  }
}
