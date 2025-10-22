import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/weekly_report_entity.dart';
import '../repositories/body_scan_repository.dart';

/// Parámetros para obtener el reporte semanal
class GetWeeklySessionsParams {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;

  GetWeeklySessionsParams({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
  });
}

/// Caso de uso para obtener el reporte semanal de sesiones
class GetWeeklySessionsUseCase
    implements UseCase<WeeklyReportEntity, GetWeeklySessionsParams> {
  final BodyScanRepository repository;

  GetWeeklySessionsUseCase({required this.repository});

  @override
  Future<Either<Failure, WeeklyReportEntity>> call(
      GetWeeklySessionsParams params) async {
    final result = await repository.getSessionsByDateRange(
      params.userId,
      params.weekStart,
      params.weekEnd,
    );

    return result.fold(
      (failure) => Left(failure),
      (sessions) {
        final report = WeeklyReportEntity(
          weekStart: params.weekStart,
          weekEnd: params.weekEnd,
          sessions: sessions,
        );
        return Right(report);
      },
    );
  }
}
