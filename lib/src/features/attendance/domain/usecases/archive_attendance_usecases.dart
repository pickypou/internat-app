import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../repositories/attendance_repository.dart';
import '../entities/attendance_archive_entity.dart';

@injectable
class GetLyceeArchiveDataUseCase {
  final AttendanceRepository _repository;

  GetLyceeArchiveDataUseCase(this._repository);

  Future<List<AttendanceArchiveEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String periodLabel,
  }) async {
    return await _repository.getLyceeArchiveData(
      startDate,
      endDate,
      periodLabel,
    );
  }
}

@injectable
class GetPolSupArchiveDataUseCase {
  final AttendanceRepository _repository;

  GetPolSupArchiveDataUseCase(this._repository);

  Future<List<AttendanceArchiveEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String periodLabel,
  }) async {
    return await _repository.getPolSupArchiveData(
      startDate,
      endDate,
      periodLabel,
    );
  }
}

@injectable
class ArchiveAndResetUseCase {
  final AttendanceRepository _repository;

  ArchiveAndResetUseCase(this._repository);

  Future<void> call({
    required List<AttendanceArchiveEntity> archives,
    required Uint8List pdfBytes,
    required String reportName,
    required String periodLabel,
  }) async {
    await _repository.archiveAndReset(
      archives: archives,
      pdfBytes: pdfBytes,
      reportName: reportName,
      periodLabel: periodLabel,
    );
  }
}
