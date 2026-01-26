import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<void> call({
    required String habitId,
    required String userId,
  }) async {
    return await repository.deleteHabit(habitId, userId);
  }
}
