import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../domain/entities/stop_session_entity.dart';
import '../../domain/entities/weekly_stop_report_entity.dart';
import '../../domain/repositories/stop_game_repository.dart';
import '../datasources/stop_game_remote_datasource.dart';
import '../models/stop_session_model.dart';

/// Implementación del repositorio de sesiones de STOP
class StopGameRepositoryImpl implements StopGameRepository {
  final StopGameDataSource dataSource;

  StopGameRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> saveSession(StopSessionEntity session) async {
    try {
      final model = StopSessionModel.fromEntity(session);
      await dataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StopSessionEntity>>> getSessionsByUser(
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
  Future<Either<Failure, WeeklyStopReportEntity>> getSessionsByDateRange(
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

      final report = WeeklyStopReportEntity(
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
