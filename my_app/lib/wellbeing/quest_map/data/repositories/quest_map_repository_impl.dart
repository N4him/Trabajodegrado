import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../domain/entities/quest_map_session_entity.dart';
import '../../domain/repositories/quest_map_repository.dart';
import '../datasources/quest_map_remote_datasource.dart';
import '../models/quest_map_session_model.dart';

/// Implementación del repositorio de Quest Map
class QuestMapRepositoryImpl implements QuestMapRepository {
  final QuestMapDataSource dataSource;

  QuestMapRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> saveSession(QuestMapSessionEntity session) async {
    try {
      final model = QuestMapSessionModel.fromEntity(session);
      await dataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestMapSessionEntity>>> getSessionsByUser(
      String userId) async {
    try {
      final models = await dataSource.fetchSessionsByUserId(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestMapSessionEntity>>> getSessionsByDateRange(
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
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
