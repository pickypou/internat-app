import 'package:injectable/injectable.dart';
import '../../../students/data/datasources/student_remote_datasource.dart';
import '../../../students/domain/entities/student_entity.dart';

const kAppelDimancheGroupId = 'appel-dimanche';
const kPolSupGroupName = 'pol-sup';

/// Use case that fetches all students from all groups except [excludedGroupName].
/// Used for the special 'appel-dimanche' virtual group.
@injectable
class GetAllStudentsUseCase {
  final StudentRemoteDataSource _dataSource;

  GetAllStudentsUseCase(this._dataSource);

  Future<List<StudentEntity>> call(String excludedGroupName) async {
    return await _dataSource.getAllStudentsExcludingGroup(excludedGroupName);
  }
}
