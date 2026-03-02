import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances(String groupId, DateTime date);
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);
}
