import 'package:injectable/injectable.dart';
import '../datasources/stage_period_remote_datasource.dart';
import '../../domain/entities/stage_period_entity.dart';
import '../../domain/repositories/stage_period_repository.dart';

@Injectable(as: StagePeriodRepository)
class StagePeriodRepositoryImpl implements StagePeriodRepository {
  final StagePeriodRemoteDataSource _dataSource;

  StagePeriodRepositoryImpl(this._dataSource);

  @override
  Future<List<StagePeriodEntity>> getStagePeriods() =>
      _dataSource.getStagePeriods();

  @override
  Future<void> upsertStagePeriod({
    required String className,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) => _dataSource.upsertStagePeriod(
    className: className,
    type: type,
    startDate: startDate,
    endDate: endDate,
  );
}
