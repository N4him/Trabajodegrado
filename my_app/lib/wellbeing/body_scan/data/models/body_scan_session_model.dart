import '../../domain/entities/body_scan_session_entity.dart';

/// Modelo de datos para sesión de Escaneo Corporal (se guarda en Firestore)
class BodyScanSessionModel {
  final String id;
  final String userId;
  final DateTime completedAt;
  final List<bool> emotionReports;
  final int rating;
  final int durationSeconds;

  BodyScanSessionModel({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.emotionReports,
    required this.rating,
    required this.durationSeconds,
  });

  /// Convierte la Entidad del Dominio a un Modelo
  factory BodyScanSessionModel.fromEntity(BodyScanSessionEntity entity) {
    return BodyScanSessionModel(
      id: entity.id,
      userId: entity.userId,
      completedAt: entity.completedAt,
      emotionReports: entity.emotionReports,
      rating: entity.rating,
      durationSeconds: entity.durationSeconds,
    );
  }

  /// Convierte el Modelo a un Map<String, dynamic> (Para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      'emotionReports': emotionReports,
      'rating': rating,
      'durationSeconds': durationSeconds,
    };
  }

  /// Crea un Modelo a partir de un Map (Para leer de Firestore)
  factory BodyScanSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return BodyScanSessionModel(
      id: id,
      userId: map['userId'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
      emotionReports: List<bool>.from(map['emotionReports'] as List),
      rating: map['rating'] as int,
      durationSeconds: map['durationSeconds'] as int,
    );
  }

  /// Convierte el Modelo de vuelta a la Entidad (Para devolver al Dominio)
  BodyScanSessionEntity toEntity() {
    return BodyScanSessionEntity(
      id: id,
      userId: userId,
      completedAt: completedAt,
      emotionReports: emotionReports,
      rating: rating,
      durationSeconds: durationSeconds,
    );
  }
}
