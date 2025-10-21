import '../entities/habit_entity.dart';
import '../entities/habit_progress.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_progress_calculator.dart';

/// Use case para obtener el progreso calculado de un hábito
class GetHabitProgressUseCase {
  final HabitRepository repository;

  GetHabitProgressUseCase({required this.repository});

  /// Obtiene el progreso calculado de un hábito específico
  Future<HabitProgress> call({
    required HabitEntity habit,
    required String userId,
  }) async {
    // 1. Obtener los registros de completitud del hábito
    final completionRecords = await repository.getCompletionRecordsForHabit(
      habit.id,
      userId,
    );

    // 2. Calcular el progreso usando el servicio
    final progress = HabitProgressCalculator.calculate(
      habit: habit,
      completionRecords: completionRecords,
    );

    return progress;
  }

  /// Obtiene el progreso de todos los hábitos de un usuario
  Future<List<HabitProgress>> getAllHabitsProgress({
    required String userId,
  }) async {
    // 1. Obtener todos los hábitos del usuario
    final habits = await repository.getHabitsByUserId(userId);

    // 2. Calcular progreso de cada hábito
    final progressList = <HabitProgress>[];

    for (final habit in habits) {
      final completionRecords = await repository.getCompletionRecordsForHabit(
        habit.id,
        userId,
      );

      final progress = HabitProgressCalculator.calculate(
        habit: habit,
        completionRecords: completionRecords,
      );

      progressList.add(progress);
    }

    return progressList;
  }
}
