import 'package:injectable/injectable.dart';
import '../repositories/stage_period_repository.dart';
import '../entities/stage_period_entity.dart';

@injectable
class GetStagePeriodsUseCase {
  final StagePeriodRepository _repository;

  GetStagePeriodsUseCase(this._repository);

  Future<List<StagePeriodEntity>> call() => _repository.getStagePeriods();
}
