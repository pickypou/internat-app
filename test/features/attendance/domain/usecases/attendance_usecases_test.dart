import 'package:flutter_test/flutter_test.dart';
import 'package:internat_app/src/features/attendance/domain/entities/attendance_entity.dart';
import 'package:internat_app/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:internat_app/src/features/attendance/domain/usecases/get_attendances_usecase.dart';
import 'package:internat_app/src/features/attendance/domain/usecases/save_attendance_usecase.dart';
import 'package:internat_app/src/features/attendance/domain/usecases/delete_attendance_usecase.dart';

// ── Manual stub ───────────────────────────────────────────────────────────────
class _FakeAttendanceRepository implements AttendanceRepository {
  final List<AttendanceEntity> _records = [
    AttendanceEntity(
      id: 'a1',
      studentId: 's1',
      checkDate: DateTime(2026, 3, 2),
      isPresentEvening: true,
      isInBus: false,
      note: '',
      groupId: 'g1',
    ),
    AttendanceEntity(
      id: 'a2',
      studentId: 's2',
      checkDate: DateTime(2026, 3, 2),
      isPresentEvening: false,
      isInBus: true,
      note: '',
      groupId: 'g1',
    ),
  ];

  AttendanceEntity? lastUpserted;
  String? lastDeletedId;

  @override
  Future<List<AttendanceEntity>> getAttendances(
    String groupId,
    DateTime date,
  ) async => _records
      .where(
        (a) =>
            a.groupId == groupId &&
            a.checkDate.year == date.year &&
            a.checkDate.month == date.month &&
            a.checkDate.day == date.day,
      )
      .toList();

  @override
  Future<AttendanceEntity> updateAttendance(AttendanceEntity attendance) async {
    lastUpserted = attendance;
    final i = _records.indexWhere((a) => a.id == attendance.id);
    if (i >= 0) {
      _records[i] = attendance;
    } else {
      _records.add(attendance);
    }
    return attendance;
  }

  @override
  Future<void> deleteAttendance(String id) async {
    lastDeletedId = id;
    _records.removeWhere((a) => a.id == id);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late _FakeAttendanceRepository repo;
  final testDate = DateTime(2026, 3, 2);

  setUp(() {
    repo = _FakeAttendanceRepository();
  });

  group('GetAttendancesUseCase', () {
    test('returns attendances for the given group and date', () async {
      final useCase = GetAttendancesUseCase(repo);
      final result = await useCase('g1', testDate);
      expect(result.length, equals(2));
      expect(result.every((a) => a.groupId == 'g1'), isTrue);
    });

    test('returns empty list for unknown group', () async {
      final useCase = GetAttendancesUseCase(repo);
      final result = await useCase('unknown', testDate);
      expect(result, isEmpty);
    });

    test('returns empty list for wrong date', () async {
      final useCase = GetAttendancesUseCase(repo);
      final result = await useCase('g1', DateTime(2026, 1, 1));
      expect(result, isEmpty);
    });
  });

  group('SaveAttendanceUseCase', () {
    test('upserts an attendance record', () async {
      final att = AttendanceEntity(
        id: 'a1',
        studentId: 's1',
        checkDate: testDate,
        isPresentEvening: false,
        isInBus: false,
        note: 'Test',
        groupId: 'g1',
      );
      final useCase = SaveAttendanceUseCase(repo);
      await useCase(att);
      expect(repo.lastUpserted?.note, equals('Test'));
    });

    test('inserts new record when id is not in the list', () async {
      final att = AttendanceEntity(
        id: 'a-new',
        studentId: 's3',
        checkDate: testDate,
        isPresentEvening: true,
        isInBus: false,
        note: '',
        groupId: 'g1',
      );
      final useCase = SaveAttendanceUseCase(repo);
      await useCase(att);
      expect(repo.lastUpserted?.studentId, equals('s3'));
      final all = await repo.getAttendances('g1', testDate);
      expect(all.any((a) => a.studentId == 's3'), isTrue);
    });
  });

  group('DeleteAttendanceUseCase', () {
    test('deletes attendance by id', () async {
      final useCase = DeleteAttendanceUseCase(repo);
      await useCase('a1');
      expect(repo.lastDeletedId, equals('a1'));
      final remaining = await repo.getAttendances('g1', testDate);
      expect(remaining.any((a) => a.id == 'a1'), isFalse);
    });
  });

  group('AttendanceEntity.computedStatus', () {
    test('returns Présent when isPresentEvening is true', () {
      final att = AttendanceEntity(
        id: '',
        studentId: '',
        checkDate: DateTime.now(),
        isPresentEvening: true,
        isInBus: false,
        note: '',
        groupId: '',
      );
      expect(att.computedStatus, equals('Présent'));
    });

    test('returns Bus when isInBus is true', () {
      final att = AttendanceEntity(
        id: '',
        studentId: '',
        checkDate: DateTime.now(),
        isPresentEvening: false,
        isInBus: true,
        note: '',
        groupId: '',
      );
      expect(att.computedStatus, equals('Bus'));
    });

    test('returns Absent by default', () {
      final att = AttendanceEntity(
        id: '',
        studentId: '',
        checkDate: DateTime.now(),
        isPresentEvening: false,
        isInBus: false,
        note: '',
        groupId: '',
      );
      expect(att.computedStatus, equals('Absent'));
    });

    test('returns Stage when note is Stage', () {
      final att = AttendanceEntity(
        id: '',
        studentId: '',
        checkDate: DateTime.now(),
        isPresentEvening: false,
        isInBus: false,
        note: 'Stage',
        groupId: '',
      );
      expect(att.computedStatus, equals('Stage'));
    });
  });
}
