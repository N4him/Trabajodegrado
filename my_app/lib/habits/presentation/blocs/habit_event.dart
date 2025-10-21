// habits/presentation/blocs/habit_event.dart

import 'package:equatable/equatable.dart';

// Base para todos los eventos del BLoC de Hábitos
abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object> get props => [];
}

// 1. Evento para crear un nuevo hábito
class CreateHabitStarted extends HabitEvent {
  final String name;
  final int frequencyDays;
  final String userId;
  final DateTime startDate;
  final String? reminderTime;

  const CreateHabitStarted({
    required this.name,
    required this.frequencyDays,
    required this.userId,
    required this.startDate,
    this.reminderTime,
  });

  @override
  List<Object> get props => [name, frequencyDays, userId, startDate];
}

// 2. Evento para obtener los hábitos del usuario actual
class FetchHabitsStarted extends HabitEvent {
  final String userId;
  
  const FetchHabitsStarted({required this.userId});

  @override
  List<Object> get props => [userId];
}

// 3. Evento para registrar un cumplimiento (marcar como hecho)
class RegisterCompletionStarted extends HabitEvent {
  final String habitId;
  final String userId;

  const RegisterCompletionStarted({
    required this.habitId,
    required this.userId,
  });

  @override
  List<Object> get props => [habitId, userId];
}

// 4. Evento para obtener el progreso de todos los hábitos
class FetchHabitsProgressStarted extends HabitEvent {
  final String userId;

  const FetchHabitsProgressStarted({required this.userId});

  @override
  List<Object> get props => [userId];
}