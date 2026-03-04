import 'package:injectable/injectable.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_archive_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

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
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance) async {
    return await _remoteDataSource.upsertAttendance(attendance);
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await _remoteDataSource.deleteAttendance(id);
  }

  @override
  Future<List<AttendanceArchiveEntity>> archiveAndResetLycee(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _remoteDataSource.archiveAndResetLycee(
      startDate,
      endDate,
      periodLabel,
    );
  }

  @override
  Future<List<AttendanceArchiveEntity>> archiveAndResetPolSup(
    DateTime startDate,
    DateTime endDate,
    String periodLabel,
  ) async {
    return await _remoteDataSource.archiveAndResetPolSup(
      startDate,
      endDate,
      periodLabel,
    );
  }
}
