import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';
import '../../../services/notification_service.dart';

class CreateHabitUseCase {
  final HabitRepository repository;
  final NotificationService? notificationService;

  CreateHabitUseCase({
    required this.repository,
    this.notificationService,
  });

  Future<void> call(HabitEntity habit) async {
    // 🔑 PUNTO DE VERIFICACIÓN 6: ¿Llegamos al Use Case?
    print('>>> 6. Use Case RECIBIDO: Llamando al Repositorio para ${habit.name}');

    // 🚨 Esta línea es crucial: si no hay await, puede fallar silenciosamente.
    await repository.createHabit(habit);

    print('>>> 7. Use Case COMPLETADO. Saliendo...');

    // Programar notificación si el hábito tiene reminderTime
    if (notificationService != null && habit.reminderTime != null) {
      await notificationService!.scheduleHabitReminder(habit);
      print('>>> 8. Notificación programada para ${habit.name} a las ${habit.reminderTime}');
    }
  }
}