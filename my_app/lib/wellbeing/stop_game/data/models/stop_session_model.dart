import '../../domain/entities/stop_session_entity.dart';

/// Modelo de datos para sesiones de STOP (Firestore)
class StopSessionModel {
  final String userId;
  final String completedAt; // ISO8601 string
  final int breathSuccesses;
  final String emotion;
  final String action;
  final int durationSeconds;

  StopSessionModel({
    required this.userId,
    required this.completedAt,
    required this.breathSuccesses,
    required this.emotion,
    required this.action,
    required this.durationSeconds,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': completedAt,
      'breathSuccesses': breathSuccesses,
      'emotion': emotion,
      'action': action,
      'durationSeconds': durationSeconds,
    };
  }

  /// Crea un modelo desde un Map de Firestore
  factory StopSessionModel.fromMap(Map<String, dynamic> map) {
    return StopSessionModel(
      userId: map['userId'] as String,
      completedAt: map['completedAt'] as String,
      breathSuccesses: map['breathSuccesses'] as int,
      emotion: map['emotion'] as String,
      action: map['action'] as String,
      durationSeconds: map['durationSeconds'] as int,
    );
  }

  /// Convierte el modelo a la entidad del dominio
  StopSessionEntity toEntity(String id) {
    return StopSessionEntity(
      id: id,
      userId: userId,
      completedAt: DateTime.parse(completedAt),
      breathSuccesses: breathSuccesses,
      emotion: emotion,
      action: action,
      durationSeconds: durationSeconds,
    );
  }

  /// Crea un modelo desde una entidad del dominio
  factory StopSessionModel.fromEntity(StopSessionEntity entity) {
    return StopSessionModel(
      userId: entity.userId,
      completedAt: entity.completedAt.toIso8601String(),
      breathSuccesses: entity.breathSuccesses,
      emotion: entity.emotion,
      action: entity.action,
      durationSeconds: entity.durationSeconds,
    );
  }
}
