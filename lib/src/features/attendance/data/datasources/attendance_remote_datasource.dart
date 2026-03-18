import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../models/attendance_model.dart';
import '../models/attendance_archive_model.dart';
import '../../domain/entities/attendance_entity.dart';

/// Virtual group constant — must not be sent as a UUID to Postgres.
const _kAppelDimancheGroupId = 'appel-dimanche';
const _kMixedPoleSupGroupId = 'mixed-pole-sup';
const _kPolSupGroupName = 'pol-sup';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceModel>> getAttendancesForGroup(
    String groupId,
    DateTime date,
  );
  Future<List<AttendanceModel>> getPoleSupAttendances(DateTime date);
  Future<AttendanceModel> upsertAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);

  /// Fetches attendances for Lycee groups to prepare archive.
  Future<List<AttendanceArchiveModel>> getLyceeArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );

  /// Fetches attendances for Pol-Sup group to prepare archive.
  Future<List<AttendanceArchiveModel>> getPolSupArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );

  /// Saves the PDF, inserts JSON report(s), and deletes active records.
  Future<void> archiveAndReset({
    required List<AttendanceArchiveModel> archives,
    required Uint8List pdfBytes,
    required String reportName,
    required String periodLabel,
  });
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
  Future<List<AttendanceModel>> getPoleSupAttendances(DateTime date) async {
    try {
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await _supabaseClient
          .from('attendance')
          .select('*, groups!inner(*)')
          .eq('groups.is_pole_sup', true)
          .eq('check_date', dateString);

      return (response as List)
          .map((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to load PoleSup attendances: $e');
    }
  }

  @override
  Future<AttendanceModel> upsertAttendance(AttendanceEntity attendance) async {
    try {
      // For the virtual appel-dimanche group, look up the student's real group_id
      // so we never store 'appel-dimanche' as a UUID in the DB.
      String effectiveGroupId = attendance.groupId;
      if (effectiveGroupId == _kAppelDimancheGroupId ||
          effectiveGroupId == _kMixedPoleSupGroupId) {
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
  Future<List<AttendanceArchiveModel>> getLyceeArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return _getArchiveData(startDate, endDate, periodLabel, excludePolSup: true);
  }

  @override
  Future<List<AttendanceArchiveModel>> getPolSupArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return _getArchiveData(
      startDate,
      endDate,
      periodLabel,
      excludePolSup: false,
    );
  }

  Future<List<AttendanceArchiveModel>> _getArchiveData(
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
      final groupsResp = await _supabaseClient.from('groups').select('id, name');
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
      if (allAttendances.isEmpty) return [];

      // 3. Filter attendances based on pol-sup rules
      final targetAttendances = allAttendances.where((att) {
        final gId = att['group_id'] as String;
        return excludePolSup
            ? !polSupIds.contains(gId)
            : polSupIds.contains(gId);
      }).toList();

      if (targetAttendances.isEmpty) return [];

      // 4. Fetch students for details
      final targetStudentIds = targetAttendances
          .map((a) => a['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final studentsResp = await _supabaseClient
          .from('students')
          .select('id, last_name, first_name, class_name, room_number')
          .inFilter('id', targetStudentIds);

      final studentMap = {
        for (final s in (studentsResp as List<dynamic>)) s['id'] as String: s,
      };

      // 5. Build models
      return targetAttendances.map((att) {
        final sId = att['student_id'] as String;
        final student = studentMap[sId];
        return AttendanceArchiveModel(
          id: '', // dummy ID for the UI
          originalAttendanceId: att['id'] as String,
          studentId: sId,
          groupId: att['group_id'] as String,
          storedLastName: student?['last_name'] ?? '',
          storedFirstName: student?['first_name'] ?? '',
          storedClassName: student?['class_name'] ?? '',
          storedRoomNumber: student?['room_number'] ?? '',
          periodLabel: periodLabel,
          checkDate: DateTime.parse(att['check_date'] as String),
          status: (att['is_present_evening'] as bool) ? 'Présent' : 'Absent',
          note: att['note'] as String?,
          archiveDate: DateTime.now(),
          checkInTime: att['check_in_time'] != null
              ? DateTime.tryParse(att['check_in_time'] as String)
              : null,
          checkOutTime: att['check_out_time'] != null
              ? DateTime.tryParse(att['check_out_time'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      throw ServerFailure('Failed to get archive data: $e');
    }
  }

  @override
  Future<void> archiveAndReset({
    required List<AttendanceArchiveModel> archives,
    required Uint8List pdfBytes,
    required String reportName,
    required String periodLabel,
  }) async {
    try {
      debugPrint('[ARCHIVE] Début de archiveAndReset pour $reportName');
      if (archives.isEmpty) {
        debugPrint('[ARCHIVE] Liste d\'archives vide, arrêt.');
        return;
      }

      // 1. Upload PDF once
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'archive_$timestamp.pdf';
      debugPrint('[ARCHIVE] Nom du fichier PDF : $fileName');

      String pdfUrl;
      try {
        debugPrint('[ARCHIVE] Tentative d\'upload du PDF...');
        await _supabaseClient.storage.from('pdf_archives').uploadBinary(
          fileName,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
        debugPrint('[ARCHIVE] Upload PDF réussi.');
        pdfUrl = _supabaseClient.storage
            .from('pdf_archives')
            .getPublicUrl(fileName);
        debugPrint('[ARCHIVE] URL publique récupérée : $pdfUrl');
      } catch (storageError) {
        debugPrint('[ARCHIVE] ERREUR STORAGE : $storageError');
        throw ServerFailure(
          'Erreur critique lors de l\'upload du PDF (Bucket: pdf_archives) : $storageError',
        );
      }

      // 2. Group by groupId and insert into attendance_history
      debugPrint('[ARCHIVE] Groupement des données par groupId...');
      final grouped = <String, List<AttendanceArchiveModel>>{};
      for (final arc in archives) {
        grouped.putIfAbsent(arc.groupId, () => []).add(arc);
      }
      debugPrint('[ARCHIVE] Nombre de groupes à traiter : ${grouped.length}');

      for (final entry in grouped.entries) {
        final gId = entry.key;
        final groupArchives = entry.value;
        debugPrint('[ARCHIVE] Traitement du groupe : $gId (${groupArchives.length} enregistrements)');

        final reportData = groupArchives.map((a) => a.toJson()).toList();

        final referenceDate = groupArchives.first.checkDate;
        final checkDateStr =
            "${referenceDate.year}-${referenceDate.month.toString().padLeft(2, '0')}-${referenceDate.day.toString().padLeft(2, '0')}";

        debugPrint('[ARCHIVE] Insertion dans attendance_history pour le groupe $gId...');
        await _supabaseClient.from('attendance_history').insert({
          'report_name': reportName.isNotEmpty ? reportName : 'Sans Nom',
          'period_label': periodLabel.isNotEmpty ? periodLabel : 'Sans Période',
          'report_data': reportData,
          'pdf_url': pdfUrl,
          'group_id': gId,
          'check_date': checkDateStr,
          'archive_date': DateTime.now().toUtc().toIso8601String(),
        });
        debugPrint('[ARCHIVE] Insertion réussie pour le groupe $gId.');
      }

      // 3. Delete from original table
      final idsToDelete = archives
          .map((a) => a.originalAttendanceId)
          .whereType<String>()
          .toList();
      debugPrint('[ARCHIVE] Nettoyage de la table active (${idsToDelete.length} IDs à supprimer)...');

      for (var i = 0; i < idsToDelete.length; i += 100) {
        final chunk = idsToDelete.skip(i).take(100).toList();
        await _supabaseClient
            .from('attendance')
            .delete()
            .inFilter('id', chunk);
      }
      debugPrint('[ARCHIVE] Archivage et réinitialisation terminés avec succès.');
    } catch (e) {
      debugPrint('[ARCHIVE] ERREUR GLOBALE : $e');
      throw ServerFailure('Failed to archive and reset: $e');
    }
  }
}
