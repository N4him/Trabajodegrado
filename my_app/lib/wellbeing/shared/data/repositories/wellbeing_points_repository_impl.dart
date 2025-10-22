import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../domain/entities/wellbeing_points_entity.dart';
import '../../domain/repositories/wellbeing_points_repository.dart';
import '../datasources/wellbeing_points_remote_datasource.dart';

/// Implementación del repositorio de puntos de bienestar
class WellbeingPointsRepositoryImpl implements WellbeingPointsRepository {
  final WellbeingPointsDataSource dataSource;

  WellbeingPointsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, WellbeingPointsEntity>> getPoints(String userId) async {
    try {
      final model = await dataSource.getPoints(userId);

      if (model == null) {
        // Si no existe, retornar entidad con 0 puntos
        return Right(WellbeingPointsEntity(
          userId: userId,
          totalPoints: 0,
          lastCompletedDates: {},
        ));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementPoints(
      String userId, String activityKey) async {
    try {
      await dataSource.incrementPoints(userId, activityKey);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
