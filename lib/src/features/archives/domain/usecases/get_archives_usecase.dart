import 'package:injectable/injectable.dart';
import '../entities/attendance_history_report.dart';
import '../repositories/archives_repository.dart';

@injectable
class GetArchivesUseCase {
  final ArchivesRepository _repository;

  GetArchivesUseCase(this._repository);

  Future<List<AttendanceHistoryReport>> call() async {
    return await _repository.getReports();
  }
}
