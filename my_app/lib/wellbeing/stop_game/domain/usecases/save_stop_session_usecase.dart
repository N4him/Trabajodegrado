import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/stop_session_entity.dart';
import '../repositories/stop_game_repository.dart';

/// Use case para guardar una sesión de STOP completada
class SaveStopSessionUseCase implements UseCase<void, StopSessionEntity> {
  final StopGameRepository repository;

  SaveStopSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(StopSessionEntity session) async {
    return await repository.saveSession(session);
  }
}
