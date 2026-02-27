import 'package:injectable/injectable.dart';
import '../repositories/group_repository.dart';

@injectable
class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<void> call(String name, String colorHex) {
    return repository.createGroup(name, colorHex);
  }
}
