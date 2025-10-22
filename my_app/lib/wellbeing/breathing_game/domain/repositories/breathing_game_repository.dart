import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../entities/breathing_session_entity.dart';
import '../entities/weekly_breathing_report_entity.dart';

/// Interfaz del repositorio de juego de respiración
abstract class BreathingGameRepository {
  /// Guarda una sesión de respiración completada
  Future<Either<Failure, void>> saveSession(BreathingSessionEntity session);

  /// Obtiene todas las sesiones de un usuario
  Future<Either<Failure, List<BreathingSessionEntity>>> getSessionsByUser(
    String userId,
  );

  /// Obtiene las sesiones dentro de un rango de fechas
  Future<Either<Failure, WeeklyBreathingReportEntity>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
