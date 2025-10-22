import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión de STOP completada
class StopSessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime completedAt;
  final int breathSuccesses; // Éxitos en las 4 rondas de respiración
  final String emotion; // Emoción identificada
  final String action; // Acción elegida
  final int durationSeconds; // Duración total de la sesión

  const StopSessionEntity({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.breathSuccesses,
    required this.emotion,
    required this.action,
    required this.durationSeconds,
  });

  /// Calcula el porcentaje de éxito en la respiración (0-100)
  double get breathSuccessRate {
    return (breathSuccesses / 4) * 100; // 4 rondas totales
  }

  /// Obtiene feedback textual basado en el desempeño
  String get performanceFeedback {
    if (breathSuccesses >= 3) return "¡Excelente control de la respiración!";
    if (breathSuccesses >= 2) return "Buen trabajo en la técnica STOP.";
    return "Sigue practicando, mejorarás con el tiempo.";
  }

  /// Verifica si la sesión fue completada exitosamente
  bool get isSuccessful => breathSuccesses >= 2;

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        breathSuccesses,
        emotion,
        action,
        durationSeconds,
      ];
}
