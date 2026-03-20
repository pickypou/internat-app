import 'package:injectable/injectable.dart';
import 'package:internat_app/src/features/archives/domain/entities/attendance_history_report.dart';
import 'package:internat_app/src/features/archives/domain/repositories/archives_repository.dart';
import '../datasources/archives_remote_datasource.dart';

@LazySingleton(as: ArchivesRepository)
class ArchivesRepositoryImpl implements ArchivesRepository {
  final ArchivesRemoteDataSource _dataSource;

  ArchivesRepositoryImpl(this._dataSource);

  @override
  Future<List<AttendanceHistoryReport>> getReports() async {
    final models = await _dataSource.fetchReports();
    return models.toList();
  }
}
