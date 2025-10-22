import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión de juego de respiración completada
class BreathingSessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime completedAt;
  final String mode; // 'calmaRapida', 'enfoqueMental', 'relajacionProfunda'
  final int successes; // Taps correctos
  final int comboCount; // Combo final
  final int cyclesCompleted; // Ciclos completados
  final int durationSeconds; // Duración total de la sesión

  const BreathingSessionEntity({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.mode,
    required this.successes,
    required this.comboCount,
    required this.cyclesCompleted,
    required this.durationSeconds,
  });

  /// Calcula el porcentaje de éxito basado en los taps totales posibles
  double get successRate {
    // Cada ciclo puede tener hasta 4 fases (inhale, hold, exhale, holdEmpty)
    // Dependiendo del modo, algunas fases pueden no existir
    // Por simplificación, asumimos 4 fases por ciclo
    final maxPossible = cyclesCompleted * 4;
    if (maxPossible == 0) return 0.0;
    return (successes / maxPossible) * 100;
  }

  /// Calcula el puntaje de la sesión (0-100)
  int get sessionScore {
    return successRate.round();
  }

  /// Obtiene feedback textual basado en el desempeño
  String get performanceFeedback {
    if (successRate >= 80) return "¡Excelente control del aliento!";
    if (successRate >= 50) return "Buen trabajo, sigue practicando.";
    return "Intenta concentrarte más la próxima vez.";
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        mode,
        successes,
        comboCount,
        cyclesCompleted,
        durationSeconds,
      ];
}
