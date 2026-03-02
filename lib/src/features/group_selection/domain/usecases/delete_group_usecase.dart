import 'package:injectable/injectable.dart';
import '../repositories/group_repository.dart';

@injectable
class DeleteGroupUseCase {
  final GroupRepository _repository;
  DeleteGroupUseCase(this._repository);

  Future<void> call(String groupId) => _repository.deleteGroup(groupId);
}
