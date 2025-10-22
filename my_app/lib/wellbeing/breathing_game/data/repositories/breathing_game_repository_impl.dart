import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../domain/entities/breathing_session_entity.dart';
import '../../domain/entities/weekly_breathing_report_entity.dart';
import '../../domain/repositories/breathing_game_repository.dart';
import '../datasources/breathing_game_remote_datasource.dart';
import '../models/breathing_session_model.dart';

/// Implementación del repositorio de sesiones de respiración
class BreathingGameRepositoryImpl implements BreathingGameRepository {
  final BreathingGameDataSource dataSource;

  BreathingGameRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> saveSession(BreathingSessionEntity session) async {
    try {
      final model = BreathingSessionModel.fromEntity(session);
      await dataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BreathingSessionEntity>>> getSessionsByUser(
    String userId,
  ) async {
    try {
      final models = await dataSource.fetchSessionsByUserId(userId);
      final entities = models
          .asMap()
          .entries
          .map((entry) => entry.value.toEntity('session_${entry.key}'))
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyBreathingReportEntity>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await dataSource.fetchSessionsByDateRange(
        userId,
        startDate,
        endDate,
      );
      final entities = models
          .asMap()
          .entries
          .map((entry) => entry.value.toEntity('session_${entry.key}'))
          .toList();

      final report = WeeklyBreathingReportEntity(
        sessions: entities,
        weekStart: startDate,
        weekEnd: endDate,
      );

      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
