import 'package:injectable/injectable.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';

/// Implementation of [StudentRepository] mapping data source to domain.
@Injectable(as: StudentRepository)
class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDataSource;

  StudentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<StudentEntity>> getStudents(String groupId) async {
    // Models returned from remote data source are automatically cast
    // to their parent StudentEntity up the chain.
    return await _remoteDataSource.getStudents(groupId);
  }

  @override
  Future<List<StudentEntity>> getPoleSupStudents() async {
    return await _remoteDataSource.getPoleSupStudents();
  }

  @override
  Future<void> addStudent(StudentEntity student) async {
    return await _remoteDataSource.addStudent(student);
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    return await _remoteDataSource.updateStudent(student);
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    return await _remoteDataSource.deleteStudent(studentId);
  }

  @override
  Future<void> deleteAllStudentsByGroupId(String groupId) async {
    return await _remoteDataSource.deleteAllStudentsByGroupId(groupId);
  }

  @override
  Future<void> deleteAllStudents() async {
    return _remoteDataSource.deleteAllStudents();
  }

  @override
  Future<void> addStudents(List<StudentEntity> students) async {
    return await _remoteDataSource.addStudents(students);
  }
}
