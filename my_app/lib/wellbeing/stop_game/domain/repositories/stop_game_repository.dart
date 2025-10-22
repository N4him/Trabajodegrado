import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../entities/stop_session_entity.dart';
import '../entities/weekly_stop_report_entity.dart';

/// Interfaz del repositorio de STOP game
abstract class StopGameRepository {
  /// Guarda una sesión de STOP completada
  Future<Either<Failure, void>> saveSession(StopSessionEntity session);

  /// Obtiene todas las sesiones de un usuario
  Future<Either<Failure, List<StopSessionEntity>>> getSessionsByUser(
    String userId,
  );

  /// Obtiene las sesiones dentro de un rango de fechas
  Future<Either<Failure, WeeklyStopReportEntity>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
