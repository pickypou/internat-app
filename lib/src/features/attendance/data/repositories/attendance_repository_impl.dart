import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_archive_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_archive_model.dart';

@Injectable(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AttendanceEntity>> getAttendances(
    String groupId,
    DateTime date,
  ) async {
    return await _remoteDataSource.getAttendancesForGroup(groupId, date);
  }

  @override
  Future<List<AttendanceEntity>> getPoleSupAttendances(DateTime date) async {
    return await _remoteDataSource.getPoleSupAttendances(date);
  }

  @override
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance) async {
    return await _remoteDataSource.upsertAttendance(attendance);
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await _remoteDataSource.deleteAttendance(id);
  }

  @override
  Future<List<AttendanceArchiveEntity>> getLyceeArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _remoteDataSource.getLyceeArchiveData(
      startDate,
      endDate,
      periodLabel,
    );
  }

  @override
  Future<List<AttendanceArchiveEntity>> getPolSupArchiveData(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _remoteDataSource.getPolSupArchiveData(
      startDate,
      endDate,
      periodLabel,
    );
  }

  @override
  Future<void> archiveAndReset({
    required List<AttendanceArchiveEntity> archives,
    required Uint8List pdfBytes,
    required String reportName,
    required String periodLabel,
  }) async {
    final models =
        archives.map((a) {
          if (a is AttendanceArchiveModel) return a;
          // In practice, they should be models if coming from our datasource,
          // but we can recreate the model if needed or just cast if we are sure.
          // For safety, we can re-map if it's a raw Entity.
          return AttendanceArchiveModel(
            id: a.id,
            originalAttendanceId: a.originalAttendanceId,
            studentId: a.studentId,
            groupId: a.groupId,
            storedLastName: a.storedLastName,
            storedFirstName: a.storedFirstName,
            storedClassName: a.storedClassName,
            storedRoomNumber: a.storedRoomNumber,
            periodLabel: a.periodLabel,
            checkDate: a.checkDate,
            status: a.status,
            note: a.note,
            archiveDate: a.archiveDate,
            checkInTime: a.checkInTime,
            checkOutTime: a.checkOutTime,
          );
        }).toList();

    await _remoteDataSource.archiveAndReset(
      archives: models,
      pdfBytes: pdfBytes,
      reportName: reportName,
      periodLabel: periodLabel,
    );
  }
}
