import 'dart:typed_data';
import '../entities/attendance_entity.dart';
import '../entities/attendance_archive_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances(String groupId, DateTime date);
  Future<List<AttendanceEntity>> getPoleSupAttendances(DateTime date);
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance);
  Future<void> deleteAttendance(String id);

  Future<List<AttendanceArchiveEntity>> getLyceeArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );

  Future<List<AttendanceArchiveEntity>> getPolSupArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  );

  Future<void> archiveAndReset({
    required List<AttendanceArchiveEntity> archives,
    required Uint8List pdfBytes,
    required String reportName,
    required String periodLabel,
  });
}
