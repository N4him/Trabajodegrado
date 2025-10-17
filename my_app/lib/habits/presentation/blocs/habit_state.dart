// habits/presentation/blocs/habit_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_progress.dart';

// Base para todos los estados del BLoC de Hábitos
abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object> get props => [];
}

// 1. Estado Inicial
class HabitInitial extends HabitState {}

// 2. Estado de Carga (cuando se realiza una operación de DB)
class HabitLoading extends HabitState {}

// 3. Estado de Éxito (para notificar que una acción funcionó)
class HabitActionSuccess extends HabitState {
  final String message;
  const HabitActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// 4. Estado de Fallo (para manejar errores de DB o lógica)
class HabitFailure extends HabitState {
  final String error;
  const HabitFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// 5. Estado de Datos (usado para mostrar la lista de hábitos)
class HabitsLoaded extends HabitState {
  final List<HabitEntity> habits;

  const HabitsLoaded({required this.habits});

  @override
  List<Object> get props => [habits];
}

// 6. Estado con progreso de hábitos cargado
class HabitsProgressLoaded extends HabitState {
  final List<HabitProgress> habitsProgress;

  const HabitsProgressLoaded({required this.habitsProgress});

  @override
  List<Object> get props => [habitsProgress];
}