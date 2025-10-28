import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/quest_map_session_entity.dart';
import '../repositories/quest_map_repository.dart';

/// Caso de uso para guardar una sesión de Quest Map
class SaveQuestMapSessionUseCase implements UseCase<void, QuestMapSessionEntity> {
  final QuestMapRepository repository;

  SaveQuestMapSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(QuestMapSessionEntity session) async {
    return await repository.saveSession(session);
  }
}
