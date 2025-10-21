// domain/repositories/habit_repository.dart

import '../entities/habit_entity.dart';
import '../entities/completion_record_entity.dart';

abstract class HabitRepository {
  // Operaciones de Hábito
  Future<void> createHabit(HabitEntity habit);
  Future<List<HabitEntity>> getHabitsByUserId(String userId);
  Future<void> updateHabit(HabitEntity habit);

  // Operaciones de Registro
  Future<void> registerCompletion(CompletionRecordEntity record);

  // MODIFICADO: Requiere el userId para la consulta anidada
  Future<List<CompletionRecordEntity>> getCompletionRecordsForHabit(String habitId, String userId);
}