import 'package:injectable/injectable.dart';
import '../repositories/group_repository.dart';

@injectable
class RenameGroupUseCase {
  final GroupRepository _repository;
  RenameGroupUseCase(this._repository);

  Future<void> call(String groupId, String newName) =>
      _repository.renameGroup(groupId, newName);
}
