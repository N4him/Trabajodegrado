import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/wellbeing_points_entity.dart';
import '../repositories/wellbeing_points_repository.dart';

/// Caso de uso para obtener los puntos de bienestar del usuario
class GetWellbeingPointsUseCase implements UseCase<WellbeingPointsEntity, String> {
  final WellbeingPointsRepository repository;

  GetWellbeingPointsUseCase({required this.repository});

  @override
  Future<Either<Failure, WellbeingPointsEntity>> call(String userId) async {
    return await repository.getPoints(userId);
  }
}
