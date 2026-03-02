import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/students/domain/entities/student_entity.dart';
import 'package:internat_app/src/features/students/domain/repositories/student_repository.dart';
import 'package:internat_app/src/features/students/domain/usecases/get_students_usecase.dart';
import 'package:internat_app/src/features/students/domain/usecases/add_student_usecase.dart';
import 'package:internat_app/src/features/students/domain/usecases/update_student_usecase.dart';
import 'package:internat_app/src/features/students/domain/usecases/delete_student_usecase.dart';
import 'package:internat_app/src/features/students/domain/usecases/delete_students_by_group_usecase.dart';

// ── Manual stub ───────────────────────────────────────────────────────────────
class _FakeStudentRepository implements StudentRepository {
  final List<StudentEntity> _students = [
    const StudentEntity(
      id: 's1',
      firstName: 'Jean',
      lastName: 'Dupont',
      roomNumber: '12',
      className: '3A',
      groupId: 'g1',
    ),
    const StudentEntity(
      id: 's2',
      firstName: 'Lucie',
      lastName: 'Martin',
      roomNumber: '5',
      className: '2B',
      groupId: 'g1',
    ),
  ];

  StudentEntity? lastAdded;
  StudentEntity? lastUpdated;
  String? lastDeletedId;
  String? lastDeletedGroupId;

  @override
  Future<List<StudentEntity>> getStudents(String groupId) async =>
      _students.where((s) => s.groupId == groupId).toList();

  @override
  Future<void> addStudent(StudentEntity student) async {
    lastAdded = student;
    _students.add(student);
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    lastUpdated = student;
    final i = _students.indexWhere((s) => s.id == student.id);
    if (i >= 0) _students[i] = student;
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    lastDeletedId = studentId;
    _students.removeWhere((s) => s.id == studentId);
  }

  @override
  Future<void> deleteAllStudentsByGroupId(String groupId) async {
    lastDeletedGroupId = groupId;
    _students.removeWhere((s) => s.groupId == groupId);
  }

  @override
  Future<void> addStudents(List<StudentEntity> students) async {
    _students.addAll(students);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late _FakeStudentRepository repo;

  setUp(() {
    repo = _FakeStudentRepository();
  });

  group('GetStudentsUseCase', () {
    test('returns students for the given groupId', () async {
      final useCase = GetStudentsUseCase(repo);
      final result = await useCase('g1');
      expect(result.length, equals(2));
      expect(result.every((s) => s.groupId == 'g1'), isTrue);
    });

    test('returns empty list when group has no students', () async {
      final useCase = GetStudentsUseCase(repo);
      final result = await useCase('unknown-group');
      expect(result, isEmpty);
    });
  });

  group('AddStudentUseCase', () {
    test('adds a student to the repository', () async {
      const newStudent = StudentEntity(
        id: 's3',
        firstName: 'Alice',
        lastName: 'Bernard',
        roomNumber: '7',
        className: '1A',
        groupId: 'g1',
      );
      final useCase = AddStudentUseCase(repo);
      await useCase(newStudent);
      expect(repo.lastAdded, equals(newStudent));
    });
  });

  group('UpdateStudentUseCase', () {
    test('updates an existing student', () async {
      const updated = StudentEntity(
        id: 's1',
        firstName: 'Jean',
        lastName: 'Dupont',
        roomNumber: '99',
        className: '3A',
        groupId: 'g1',
      );
      final useCase = UpdateStudentUseCase(repo);
      await useCase(updated);
      expect(repo.lastUpdated?.roomNumber, equals('99'));
    });
  });

  group('DeleteStudentUseCase', () {
    test('deletes student with given id', () async {
      final useCase = DeleteStudentUseCase(repo);
      await useCase('s1');
      expect(repo.lastDeletedId, equals('s1'));
    });
  });

  group('DeleteStudentsByGroupUseCase', () {
    test('deletes all students belonging to the given group', () async {
      final useCase = DeleteStudentsByGroupUseCase(repo);
      await useCase('g1');
      expect(repo.lastDeletedGroupId, equals('g1'));
      final remaining = await repo.getStudents('g1');
      expect(remaining, isEmpty);
    });
  });
}
