import 'package:injectable/injectable.dart';
import '../repositories/group_repository.dart';

@injectable
class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<void> call(String name, String colorHex, {bool isPoleSup = false}) {
    return repository.createGroup(name, colorHex, isPoleSup: isPoleSup);
  }
}
