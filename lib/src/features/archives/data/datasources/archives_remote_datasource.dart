import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_history_report_model.dart';

abstract class ArchivesRemoteDataSource {
  Future<List<AttendanceHistoryReportModel>> fetchReports();
}

@Injectable(as: ArchivesRemoteDataSource)
class ArchivesRemoteDataSourceImpl implements ArchivesRemoteDataSource {
  final SupabaseClient _client;
  ArchivesRemoteDataSourceImpl(this._client);

  @override
  Future<List<AttendanceHistoryReportModel>> fetchReports() async {
    final response = await _client
        .from('attendance_history')
        .select()
        .order('archive_date', ascending: false);

    return (response as List)
        .map((json) => AttendanceHistoryReportModel.fromJson(json))
        .toList();
  }
}
