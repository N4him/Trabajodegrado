import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../entities/wellbeing_points_entity.dart';

/// Repositorio abstracto para puntos de bienestar
abstract class WellbeingPointsRepository {
  Future<Either<Failure, WellbeingPointsEntity>> getPoints(String userId);
  Future<Either<Failure, void>> incrementPoints(String userId, String activityKey);
}
