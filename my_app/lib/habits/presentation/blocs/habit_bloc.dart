// habits/presentation/blocs/habit_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'habit_event.dart';
import 'habit_state.dart';
// Importa tus Use Cases
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/register_completion_usecase.dart';
import '../../domain/usecases/get_habits_by_user_usecase.dart';
import '../../domain/usecases/get_habit_progress_usecase.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/completion_record_entity.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabitUseCase createHabitUseCase;
  final RegisterCompletionUseCase registerCompletionUseCase;
  final GetHabitsByUserUseCase getHabitsByUserUseCase;
  final GetHabitProgressUseCase getHabitProgressUseCase;

  HabitBloc({
    required this.createHabitUseCase,
    required this.registerCompletionUseCase,
    required this.getHabitsByUserUseCase,
    required this.getHabitProgressUseCase,
  }) : super(HabitInitial()) {

    // Configuración de los handlers de eventos
    on<CreateHabitStarted>(_onCreateHabit);
    on<RegisterCompletionStarted>(_onRegisterCompletion);
    on<FetchHabitsStarted>(_onFetchHabits);
    on<FetchHabitsProgressStarted>(_onFetchHabitsProgress);
  }

  // --- Handlers de Eventos (Lógica Pendiente) ---

  Future<void> _onCreateHabit(
    CreateHabitStarted event,
    Emitter<HabitState> emit,
) async {
    print('>>> 3. BLoC Handler RECIBIDO: Evento CreateHabitStarted para ${event.name}');

    emit(HabitLoading());

    try {
        // 1. CONSTRUIR LA ENTIDAD con todos los datos del evento
        final newHabit = HabitEntity(
            id: '',
            name: event.name,
            frequencyDays: event.frequencyDays,
            userId: event.userId,
            startDate: event.startDate,
            reminderTime: event.reminderTime,
        );

        print('>>> 4. BLoC LLAMANDO al CreateHabitUseCase...');

        await createHabitUseCase.call(newHabit);

        // 3. Emitir Éxito REAL después de que el Use Case retorne
        print('>>> 5. BLoC ÉXITO. Hábito guardado en DB.');
        emit(HabitActionSuccess(message: 'Hábito "${event.name}" guardado exitosamente.'));

    } catch (e) {
        // 4. Emitir Fallo si el Use Case o Firestore fallan
        print('>>> ❌ FALLO en BLoC/Use Case: $e');
        emit(HabitFailure(error: 'Fallo al guardar: ${e.toString()}'));
    }
}

  Future<void> _onRegisterCompletion(
    RegisterCompletionStarted event,
    Emitter<HabitState> emit,
  ) async {
    print('>>> BLoC: Registrando completitud para hábito ${event.habitId}');
    emit(HabitLoading());

    try {
      // Crear registro de completitud para HOY
      final now = DateTime.now();

      await registerCompletionUseCase.call(
        habitId: event.habitId,
        userId: event.userId,
        date: now,
      );

      print('>>> BLoC: Completitud registrada exitosamente');
      emit(HabitActionSuccess(message: 'Hábito marcado como completado'));
    } catch (e) {
      print('>>> ❌ BLoC: Error al registrar completitud: $e');
      emit(HabitFailure(error: 'Error al marcar hábito: ${e.toString()}'));
    }
  }

  Future<void> _onFetchHabits(
    FetchHabitsStarted event,
    Emitter<HabitState> emit,
  ) async {
    print('>>> BLoC: Obteniendo hábitos para usuario ${event.userId}');
    emit(HabitLoading());

    try {
      final habits = await getHabitsByUserUseCase.call(event.userId);
      print('>>> BLoC: ${habits.length} hábitos cargados exitosamente');
      emit(HabitsLoaded(habits: habits));
    } catch (e) {
      print('>>> ❌ BLoC: Error al obtener hábitos: $e');
      emit(HabitFailure(error: 'Error al cargar hábitos: ${e.toString()}'));
    }
  }

  Future<void> _onFetchHabitsProgress(
    FetchHabitsProgressStarted event,
    Emitter<HabitState> emit,
  ) async {
    print('>>> BLoC: Obteniendo progreso de hábitos para usuario ${event.userId}');
    emit(HabitLoading());

    try {
      final habitsProgress = await getHabitProgressUseCase.getAllHabitsProgress(
        userId: event.userId,
      );
      print('>>> BLoC: Progreso de ${habitsProgress.length} hábitos calculado');
      emit(HabitsProgressLoaded(habitsProgress: habitsProgress));
    } catch (e) {
      print('>>> ❌ BLoC: Error al obtener progreso: $e');
      emit(HabitFailure(error: 'Error al cargar progreso: ${e.toString()}'));
    }
  }
}