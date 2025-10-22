import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../repositories/wellbeing_points_repository.dart';

/// Parámetros para incrementar puntos de bienestar
class IncrementPointsParams {
  final String userId;
  final String activityKey;

  IncrementPointsParams({
    required this.userId,
    required this.activityKey,
  });
}

/// Caso de uso para incrementar puntos de bienestar
class IncrementWellbeingPointsUseCase
    implements UseCase<void, IncrementPointsParams> {
  final WellbeingPointsRepository repository;

  IncrementWellbeingPointsUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(IncrementPointsParams params) async {
    return await repository.incrementPoints(
      params.userId,
      params.activityKey,
    );
  }
}
