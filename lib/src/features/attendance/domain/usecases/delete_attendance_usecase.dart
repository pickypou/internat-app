import 'package:injectable/injectable.dart';
import '../repositories/attendance_repository.dart';

@injectable
class DeleteAttendanceUseCase {
  final AttendanceRepository repository;

  DeleteAttendanceUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAttendance(id);
  }
}
