import '../../domain/entities/quest_map_session_entity.dart';

/// Modelo de datos para Quest Map Session (Firestore)
class QuestMapSessionModel {
  final String? id;
  final String userId;
  final String completedAt; // ISO 8601
  final List<String> sightAnswers;
  final List<String> touchAnswers;
  final List<String> soundAnswers;
  final List<String> smellAnswers;
  final List<String> tasteAnswers;
  final int durationSeconds;

  QuestMapSessionModel({
    this.id,
    required this.userId,
    required this.completedAt,
    required this.sightAnswers,
    required this.touchAnswers,
    required this.soundAnswers,
    required this.smellAnswers,
    required this.tasteAnswers,
    required this.durationSeconds,
  });

  /// Convierte el modelo a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': completedAt,
      'sightAnswers': sightAnswers,
      'touchAnswers': touchAnswers,
      'soundAnswers': soundAnswers,
      'smellAnswers': smellAnswers,
      'tasteAnswers': tasteAnswers,
      'durationSeconds': durationSeconds,
    };
  }

  /// Crea un modelo desde un Map de Firestore
  factory QuestMapSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestMapSessionModel(
      id: id,
      userId: map['userId'] ?? '',
      completedAt: map['completedAt'] ?? '',
      sightAnswers: List<String>.from(map['sightAnswers'] ?? []),
      touchAnswers: List<String>.from(map['touchAnswers'] ?? []),
      soundAnswers: List<String>.from(map['soundAnswers'] ?? []),
      smellAnswers: List<String>.from(map['smellAnswers'] ?? []),
      tasteAnswers: List<String>.from(map['tasteAnswers'] ?? []),
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }

  /// Convierte el modelo a entidad de dominio
  QuestMapSessionEntity toEntity() {
    return QuestMapSessionEntity(
      id: id,
      userId: userId,
      completedAt: DateTime.parse(completedAt),
      sightAnswers: sightAnswers,
      touchAnswers: touchAnswers,
      soundAnswers: soundAnswers,
      smellAnswers: smellAnswers,
      tasteAnswers: tasteAnswers,
      durationSeconds: durationSeconds,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory QuestMapSessionModel.fromEntity(QuestMapSessionEntity entity) {
    return QuestMapSessionModel(
      id: entity.id,
      userId: entity.userId,
      completedAt: entity.completedAt.toIso8601String(),
      sightAnswers: entity.sightAnswers,
      touchAnswers: entity.touchAnswers,
      soundAnswers: entity.soundAnswers,
      smellAnswers: entity.smellAnswers,
      tasteAnswers: entity.tasteAnswers,
      durationSeconds: entity.durationSeconds,
    );
  }
}
