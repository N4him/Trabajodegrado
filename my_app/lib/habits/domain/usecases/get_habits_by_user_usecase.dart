import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class GetHabitsByUserUseCase {
  final HabitRepository repository;

  GetHabitsByUserUseCase({required this.repository});

  Future<List<HabitEntity>> call(String userId) async {
    print('>>> Use Case: Obteniendo hábitos para usuario $userId');
    final habits = await repository.getHabitsByUserId(userId);
    print('>>> Use Case: ${habits.length} hábitos obtenidos');
    return habits;
  }
}
