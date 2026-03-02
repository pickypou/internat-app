import 'package:injectable/injectable.dart';
import '../repositories/student_repository.dart';

/// Deletes all students belonging to the given group.
@injectable
class DeleteStudentsByGroupUseCase {
  final StudentRepository _repository;
  DeleteStudentsByGroupUseCase(this._repository);

  Future<void> call(String groupId) async {
    return await _repository.deleteAllStudentsByGroupId(groupId);
  }
}
