import 'package:injectable/injectable.dart';
import '../repositories/student_repository.dart';

/// Deletes all students from the database.
@injectable
class DeleteAllStudentsUseCase {
  final StudentRepository _repository;
  DeleteAllStudentsUseCase(this._repository);

  Future<void> call() async {
    return await _repository.deleteAllStudents();
  }
}
