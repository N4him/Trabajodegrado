import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/breathing_session_entity.dart';
import '../repositories/breathing_game_repository.dart';

/// Use case para guardar una sesión de respiración completada
class SaveBreathingSessionUseCase implements UseCase<void, BreathingSessionEntity> {
  final BreathingGameRepository repository;

  SaveBreathingSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(BreathingSessionEntity session) async {
    return await repository.saveSession(session);
  }
}
