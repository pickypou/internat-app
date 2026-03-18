import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_history_report.dart';

class ArchivesRemoteDataSource {
  final SupabaseClient _client;
  ArchivesRemoteDataSource(this._client);

  Future<List<AttendanceHistoryReport>> fetchReports() async {
    final response = await _client
        .from('attendance_history')
        .select()
        .order('archive_date', ascending: false);

    return (response as List)
        .map((json) => AttendanceHistoryReport.fromJson(json))
        .toList();
  }
}
