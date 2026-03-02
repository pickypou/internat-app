import 'package:injectable/injectable.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@injectable
class AddStudentUseCase {
  final StudentRepository _repository;

  AddStudentUseCase(this._repository);

  Future<void> call(StudentEntity student) async {
    return await _repository.addStudent(student);
  }
}
