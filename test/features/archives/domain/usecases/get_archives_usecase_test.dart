import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internat_app/src/features/archives/domain/entities/attendance_history_report.dart';
import 'package:internat_app/src/features/archives/domain/repositories/archives_repository.dart';
import 'package:internat_app/src/features/archives/domain/usecases/get_archives_usecase.dart';

class MockArchivesRepository extends Mock implements ArchivesRepository {}

void main() {
  late GetArchivesUseCase useCase;
  late MockArchivesRepository mockRepository;

  setUp(() {
    mockRepository = MockArchivesRepository();
    useCase = GetArchivesUseCase(mockRepository);
  });

  final tReports = [
    AttendanceHistoryReport(
      id: '1',
      reportName: 'Test Report',
      periodLabel: 'Week 1',
      groupId: 'group1',
      checkDate: DateTime(2024, 3, 1),
      archiveDate: DateTime(2024, 3, 2),
      reportData: const [],
    ),
  ];

  test('should get reports from the repository', () async {
    // arrange
    when(() => mockRepository.getReports()).thenAnswer((_) async => tReports);

    // act
    final result = await useCase();

    // assert
    expect(result, tReports);
    verify(() => mockRepository.getReports());
    verifyNoMoreInteractions(mockRepository);
  });
}
