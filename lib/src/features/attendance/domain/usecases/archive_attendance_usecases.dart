import 'package:injectable/injectable.dart';
import '../repositories/attendance_repository.dart';
import '../entities/attendance_archive_entity.dart';

@injectable
class ArchiveAndResetLyceeUseCase {
  final AttendanceRepository _repository;

  ArchiveAndResetLyceeUseCase(this._repository);

  Future<List<AttendanceArchiveEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String periodLabel,
  }) async {
    return await _repository.archiveAndResetLycee(
      startDate,
      endDate,
      periodLabel,
    );
  }
}

@injectable
class ArchiveAndResetPolSupUseCase {
  final AttendanceRepository _repository;

  ArchiveAndResetPolSupUseCase(this._repository);

  Future<List<AttendanceArchiveEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String periodLabel,
  }) async {
    return await _repository.archiveAndResetPolSup(
      startDate,
      endDate,
      periodLabel,
    );
  }
}
