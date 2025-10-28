import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../entities/quest_map_session_entity.dart';

/// Repositorio abstracto para Quest Map (técnica 5-4-3-2-1)
abstract class QuestMapRepository {
  /// Guarda una sesión completada
  Future<Either<Failure, void>> saveSession(QuestMapSessionEntity session);

  /// Obtiene todas las sesiones de un usuario
  Future<Either<Failure, List<QuestMapSessionEntity>>> getSessionsByUser(
      String userId);

  /// Obtiene sesiones en un rango de fechas
  Future<Either<Failure, List<QuestMapSessionEntity>>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
