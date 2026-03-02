import '../../domain/entities/stage_period_entity.dart';

abstract class StagePeriodRepository {
  Future<List<StagePeriodEntity>> getStagePeriods();
  Future<void> upsertStagePeriod({
    required String className,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });
}
