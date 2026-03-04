import '../entities/attendance_entity.dart';
import '../entities/attendance_archive_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances(String groupId, DateTime date);
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);
  Future<List<AttendanceArchiveEntity>> archiveAndResetLycee(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );
  Future<List<AttendanceArchiveEntity>> archiveAndResetPolSup(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );
}
