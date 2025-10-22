import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/weekly_stop_report_entity.dart';
import '../repositories/stop_game_repository.dart';

/// Parámetros para obtener sesiones semanales de STOP
class GetWeeklyStopSessionsParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetWeeklyStopSessionsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}

/// Use case para obtener reporte semanal de sesiones de STOP
class GetWeeklyStopSessionsUseCase
    implements UseCase<WeeklyStopReportEntity, GetWeeklyStopSessionsParams> {
  final StopGameRepository repository;

  GetWeeklyStopSessionsUseCase({required this.repository});

  @override
  Future<Either<Failure, WeeklyStopReportEntity>> call(
    GetWeeklyStopSessionsParams params,
  ) async {
    return await repository.getSessionsByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}
