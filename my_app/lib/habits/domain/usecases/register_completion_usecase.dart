// domain/usecases/register_completion_usecase.dart

import '../entities/completion_record_entity.dart';
import '../repositories/habit_repository.dart';

class RegisterCompletionUseCase {
  final HabitRepository repository;
  RegisterCompletionUseCase(this.repository);

  Future<void> call({
    required String habitId, 
    required DateTime date, 
    required String userId, // Proveniente de FirebaseAuth.currentUser.uid
  }) {
    // Construye la entidad COMPLETA
    final record = CompletionRecordEntity(
      id: '', 
      userId: userId, 
      habitId: habitId,
      date: DateTime(date.year, date.month, date.day),
      isCompleted: true, 
      registeredAt: DateTime.now(),
    );
    return repository.registerCompletion(record);
  }
}