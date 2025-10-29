import '../../domain/entities/breathing_session_entity.dart';

/// Modelo de datos para sesiones de respiración (Firestore)
class BreathingSessionModel {
  final String userId;
  final String completedAt; // ISO8601 string
  final String mode;
  final int particlesCollected;
  final int totalParticles;
  final int cyclesCompleted;
  final int durationSeconds;

  BreathingSessionModel({
    required this.userId,
    required this.completedAt,
    required this.mode,
    required this.particlesCollected,
    required this.totalParticles,
    required this.cyclesCompleted,
    required this.durationSeconds,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': completedAt,
      'mode': mode,
      'particlesCollected': particlesCollected,
      'totalParticles': totalParticles,
      'cyclesCompleted': cyclesCompleted,
      'durationSeconds': durationSeconds,
    };
  }

  /// Crea un modelo desde un Map de Firestore
  factory BreathingSessionModel.fromMap(Map<String, dynamic> map) {
    return BreathingSessionModel(
      userId: map['userId'] as String,
      completedAt: map['completedAt'] as String,
      mode: map['mode'] as String,
      particlesCollected: map['particlesCollected'] as int? ?? 0,
      totalParticles: map['totalParticles'] as int? ?? 0,
      cyclesCompleted: map['cyclesCompleted'] as int,
      durationSeconds: map['durationSeconds'] as int,
    );
  }

  /// Convierte el modelo a la entidad del dominio
  BreathingSessionEntity toEntity(String id) {
    return BreathingSessionEntity(
      id: id,
      userId: userId,
      completedAt: DateTime.parse(completedAt),
      mode: mode,
      particlesCollected: particlesCollected,
      totalParticles: totalParticles,
      cyclesCompleted: cyclesCompleted,
      durationSeconds: durationSeconds,
    );
  }

  /// Crea un modelo desde una entidad del dominio
  factory BreathingSessionModel.fromEntity(BreathingSessionEntity entity) {
    return BreathingSessionModel(
      userId: entity.userId,
      completedAt: entity.completedAt.toIso8601String(),
      mode: entity.mode,
      particlesCollected: entity.particlesCollected,
      totalParticles: entity.totalParticles,
      cyclesCompleted: entity.cyclesCompleted,
      durationSeconds: entity.durationSeconds,
    );
  }
}
