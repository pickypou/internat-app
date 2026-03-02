import '../entities/student_entity.dart';

/// Abstract repository interface for student-related data operations.
abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents(String groupId);
  Future<void> addStudent(StudentEntity student);
  Future<void> updateStudent(StudentEntity student);
  Future<void> deleteStudent(String studentId);
  Future<void> deleteAllStudentsByGroupId(String groupId);
  Future<void> addStudents(List<StudentEntity> students);
}
