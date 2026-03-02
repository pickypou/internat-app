import 'package:injectable/injectable.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@injectable
class UpdateStudentUseCase {
  final StudentRepository _repository;

  UpdateStudentUseCase(this._repository);

  Future<void> call(StudentEntity student) async {
    return await _repository.updateStudent(student);
  }
}
