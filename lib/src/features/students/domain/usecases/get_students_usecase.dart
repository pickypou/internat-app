import 'package:injectable/injectable.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@injectable
class GetStudentsUseCase {
  final StudentRepository _repository;

  GetStudentsUseCase(this._repository);

  Future<List<StudentEntity>> call(String groupId) async {
    final students = await _repository.getStudents(groupId);
    students.sort((a, b) {
      final lastCmp = a.lastName.toLowerCase().compareTo(
        b.lastName.toLowerCase(),
      );
      if (lastCmp != 0) return lastCmp;
      return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
    });
    return students;
  }
}
