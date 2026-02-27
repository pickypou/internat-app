import 'package:injectable/injectable.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@injectable
class GetGroupsUseCase {
  final GroupRepository repository;

  GetGroupsUseCase(this.repository);

  Future<List<GroupEntity>> call() {
    return repository.getGroups();
  }
}
