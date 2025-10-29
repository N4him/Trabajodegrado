import 'package:equatable/equatable.dart';
import '../../domain/models/breathing_mode.dart';

/// Base de todos los eventos de respiración
abstract class BreathingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Inicia el juego con un modo seleccionado
class StartBreathingGame extends BreathingEvent {
  final BreathingMode mode;

  StartBreathingGame(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Actualiza el progreso de la fase (de 0.0 a 1.0)
class PhaseTick extends BreathingEvent {
  final double elapsed;

  PhaseTick(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

/// El usuario recolecta una partícula
class CollectParticle extends BreathingEvent {
  final int particleId;

  CollectParticle(this.particleId);

  @override
  List<Object?> get props => [particleId];
}

/// Se completa la fase actual (tiempo alcanza 100%)
class PhaseComplete extends BreathingEvent {}

/// Reinicia el juego
class ResetBreathingGame extends BreathingEvent {}
