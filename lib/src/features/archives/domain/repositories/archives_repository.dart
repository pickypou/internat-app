import '../entities/attendance_history_report.dart';

abstract class ArchivesRepository {
  Future<List<AttendanceHistoryReport>> getReports();
}
