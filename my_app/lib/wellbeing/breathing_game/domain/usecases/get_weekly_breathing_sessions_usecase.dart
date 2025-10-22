import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/weekly_breathing_report_entity.dart';
import '../repositories/breathing_game_repository.dart';

/// Parámetros para obtener sesiones semanales
class GetWeeklyBreathingSessionsParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetWeeklyBreathingSessionsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}

/// Use case para obtener reporte semanal de sesiones de respiración
class GetWeeklyBreathingSessionsUseCase
    implements UseCase<WeeklyBreathingReportEntity, GetWeeklyBreathingSessionsParams> {
  final BreathingGameRepository repository;

  GetWeeklyBreathingSessionsUseCase({required this.repository});

  @override
  Future<Either<Failure, WeeklyBreathingReportEntity>> call(
    GetWeeklyBreathingSessionsParams params,
  ) async {
    return await repository.getSessionsByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}
