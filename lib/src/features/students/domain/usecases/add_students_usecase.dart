import 'package:injectable/injectable.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@injectable
class AddStudentsUseCase {
  final StudentRepository _repository;

  AddStudentsUseCase(this._repository);

  Future<void> call(List<StudentEntity> students) async {
    return await _repository.addStudents(students);
  }
}
