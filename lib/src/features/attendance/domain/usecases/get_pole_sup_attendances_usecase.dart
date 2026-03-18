import 'package:injectable/injectable.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

@injectable
class GetPoleSupAttendancesUseCase {
  final AttendanceRepository repository;

  GetPoleSupAttendancesUseCase(this.repository);

  Future<List<AttendanceEntity>> call(DateTime date) async {
    return await repository.getPoleSupAttendances(date);
  }
}
