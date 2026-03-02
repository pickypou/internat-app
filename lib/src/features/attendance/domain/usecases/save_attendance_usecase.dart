import 'package:injectable/injectable.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

@injectable
class SaveAttendanceUseCase {
  final AttendanceRepository _repository;

  SaveAttendanceUseCase(this._repository);

  Future<AttendanceEntity> call(AttendanceEntity attendance) async {
    return await _repository.updateAttendance(attendance);
  }
}
