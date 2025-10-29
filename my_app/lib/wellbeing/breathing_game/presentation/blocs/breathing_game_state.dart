import 'package:equatable/equatable.dart';
import '../../domain/models/breathing_mode.dart';

/// Fases del ciclo de respiración
enum BreathingPhase {
  inhale,
  secondInhale, // Solo para Cyclic Sighing
  hold,
  exhale,
  holdEmpty,
}

/// Estados del juego de respiración
abstract class BreathingGameState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BreathingInitial extends BreathingGameState {}

/// Fase en progreso
class PhaseInProgress extends BreathingGameState {
  final BreathingPhase phase;
  final double elapsed; // 0.0-1.0
  final int cycleCount; // Ciclo actual (0-based)
  final int particlesCollected; // Partículas recolectadas
  final int totalParticles; // Total de partículas generadas
  final DateTime startTime; // Tiempo de inicio de la sesión

  PhaseInProgress({
    required this.phase,
    required this.elapsed,
    required this.cycleCount,
    required this.particlesCollected,
    required this.totalParticles,
    required this.startTime,
  });

  @override
  List<Object?> get props => [phase, elapsed, cycleCount, particlesCollected, totalParticles, startTime];
}

/// Sesión completada
class SessionCompleted extends BreathingGameState {
  final BreathingMode mode;
  final int particlesCollected;
  final int totalParticles;
  final int cyclesCompleted;
  final int durationSeconds;

  SessionCompleted({
    required this.mode,
    required this.particlesCollected,
    required this.totalParticles,
    required this.cyclesCompleted,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [mode, particlesCollected, totalParticles, cyclesCompleted, durationSeconds];
}

/// Guardando sesión
class SavingSession extends BreathingGameState {}

/// Sesión guardada exitosamente
class SessionSaved extends BreathingGameState {
  final BreathingMode mode;
  final int particlesCollected;
  final int totalParticles;
  final int cyclesCompleted;
  final int durationSeconds;

  SessionSaved({
    required this.mode,
    required this.particlesCollected,
    required this.totalParticles,
    required this.cyclesCompleted,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [mode, particlesCollected, totalParticles, cyclesCompleted, durationSeconds];
}

/// Error al guardar
class BreathingError extends BreathingGameState {
  final String message;

  BreathingError(this.message);

  @override
  List<Object?> get props => [message];
}
