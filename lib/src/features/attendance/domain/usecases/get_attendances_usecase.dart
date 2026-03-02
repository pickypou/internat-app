import 'package:injectable/injectable.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

@injectable
class GetAttendancesUseCase {
  final AttendanceRepository _repository;

  GetAttendancesUseCase(this._repository);

  Future<List<AttendanceEntity>> call(String groupId, DateTime date) async {
    return await _repository.getAttendances(groupId, date);
  }
}
