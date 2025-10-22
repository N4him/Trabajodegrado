import 'package:equatable/equatable.dart';

/// Eventos para el STOP game
abstract class StopGameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Inicia el juego STOP
class StartStopGame extends StopGameEvent {}

/// Paso 1: el usuario presiona STOP
class StopPressed extends StopGameEvent {}

/// Paso 2: el usuario hace tap durante la respiración
class BreatheTapped extends StopGameEvent {
  final bool success;

  BreatheTapped(this.success);

  @override
  List<Object?> get props => [success];
}

/// Paso 3: el usuario identifica una emoción
class EmotionIdentified extends StopGameEvent {
  final String emotion;

  EmotionIdentified(this.emotion);

  @override
  List<Object?> get props => [emotion];
}

/// Paso 4: el usuario elige una acción
class ActionChosen extends StopGameEvent {
  final String action;

  ActionChosen(this.action);

  @override
  List<Object?> get props => [action];
}

/// Resetea el juego
class ResetStopGame extends StopGameEvent {}
