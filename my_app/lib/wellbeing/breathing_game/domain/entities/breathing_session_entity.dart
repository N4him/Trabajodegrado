import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión de juego de respiración completada
class BreathingSessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime completedAt;
  final String mode; // 'cyclicSighing', 'boxBreathing', 'cyclicHyperventilation'
  final int particlesCollected; // Partículas recolectadas
  final int totalParticles; // Total de partículas que aparecieron
  final int cyclesCompleted; // Ciclos completados
  final int durationSeconds; // Duración total de la sesión

  const BreathingSessionEntity({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.mode,
    required this.particlesCollected,
    required this.totalParticles,
    required this.cyclesCompleted,
    required this.durationSeconds,
  });

  /// Calcula el porcentaje de recolección de partículas
  double get collectionRate {
    if (totalParticles == 0) return 0.0;
    return (particlesCollected / totalParticles) * 100;
  }

  /// Calcula el puntaje de la sesión (0-100)
  int get sessionScore {
    return collectionRate.round();
  }

  /// Obtiene feedback textual basado en el desempeño
  String get performanceFeedback {
    if (collectionRate >= 70) return "¡Excelente concentración y atención!";
    if (collectionRate >= 40) return "Buen trabajo, mantén el ritmo.";
    return "Recuerda que recolectar es opcional, lo importante es respirar.";
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        mode,
        particlesCollected,
        totalParticles,
        cyclesCompleted,
        durationSeconds,
      ];
}
