import 'package:injectable/injectable.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@injectable
class GetPoleSupStudentsUseCase {
  final StudentRepository repository;

  GetPoleSupStudentsUseCase(this.repository);

  Future<List<StudentEntity>> call() async {
    return await repository.getPoleSupStudents();
  }
}
