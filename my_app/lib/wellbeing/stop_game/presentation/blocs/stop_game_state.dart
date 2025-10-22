import 'package:equatable/equatable.dart';

/// Estados del STOP game
abstract class StopGameState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class StopInitial extends StopGameState {}

/// Estado durante las rondas de respiración
class BreathingState extends StopGameState {
  final int round; // Ronda actual (1-4)
  final int successes; // Éxitos acumulados
  final DateTime startTime; // Tiempo de inicio de la sesión

  BreathingState({
    required this.round,
    required this.successes,
    required this.startTime,
  });

  @override
  List<Object?> get props => [round, successes, startTime];
}

/// Estado para identificar emoción
class EmotionState extends StopGameState {
  final List<String> availableEmotions;
  final String? selected;
  final int breathSuccesses;
  final DateTime startTime;

  EmotionState({
    required this.availableEmotions,
    this.selected,
    required this.breathSuccesses,
    required this.startTime,
  });

  @override
  List<Object?> get props => [availableEmotions, selected, breathSuccesses, startTime];
}

/// Estado para elegir acción
class ActionState extends StopGameState {
  final List<String> options;
  final String? chosen;
  final String emotion;
  final int breathSuccesses;
  final DateTime startTime;

  ActionState({
    required this.options,
    this.chosen,
    required this.emotion,
    required this.breathSuccesses,
    required this.startTime,
  });

  @override
  List<Object?> get props => [options, chosen, emotion, breathSuccesses, startTime];
}

/// Estado de guardando sesión
class SavingSession extends StopGameState {}

/// Estado de sesión completada y guardada
class SessionSaved extends StopGameState {
  final int breathSuccesses;
  final String emotion;
  final String action;
  final int durationSeconds;

  SessionSaved({
    required this.breathSuccesses,
    required this.emotion,
    required this.action,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [breathSuccesses, emotion, action, durationSeconds];
}

/// Estado de error
class StopGameError extends StopGameState {
  final String message;

  StopGameError(this.message);

  @override
  List<Object?> get props => [message];
}
