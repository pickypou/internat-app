import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/stage_period_entity.dart';
import '../../../../shared/error/failure.dart';

abstract class StagePeriodRemoteDataSource {
  Future<List<StagePeriodEntity>> getStagePeriods();
  Future<void> upsertStagePeriod({
    required String className,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });
}

@Injectable(as: StagePeriodRemoteDataSource)
class StagePeriodRemoteDataSourceImpl implements StagePeriodRemoteDataSource {
  final SupabaseClient _client;

  StagePeriodRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _client = supabaseClient;

  @override
  Future<List<StagePeriodEntity>> getStagePeriods() async {
    try {
      final data = await _client
          .from('class_schedules')
          .select()
          .order('start_date', ascending: true);

      return (data as List)
          .map(
            (row) => StagePeriodEntity(
              id: row['id']?.toString() ?? '',
              className: row['class_name'] as String,
              type: (row['type'] as String?) ?? 'PRESENCE',
              startDate: DateTime.parse(row['start_date'] as String),
              endDate: DateTime.parse(row['end_date'] as String),
            ),
          )
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to load stage periods: $e');
    }
  }

  @override
  Future<void> upsertStagePeriod({
    required String className,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Upsert on (class_name, start_date) — update if same class + start date exist
      await _client.from('class_schedules').upsert({
        'class_name': className,
        'type': type,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
      }, onConflict: 'class_name,start_date');
    } catch (e) {
      throw ServerFailure('Failed to upsert stage period: $e');
    }
  }
}
