import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;
  
  CreateHabitUseCase({required this.repository});

  Future<void> call(HabitEntity habit) async {
    // 🔑 PUNTO DE VERIFICACIÓN 6: ¿Llegamos al Use Case?
    print('>>> 6. Use Case RECIBIDO: Llamando al Repositorio para ${habit.name}'); 

    // 🚨 Esta línea es crucial: si no hay await, puede fallar silenciosamente.
    await repository.createHabit(habit); 
    
    print('>>> 7. Use Case COMPLETADO. Saliendo...');
  }
}