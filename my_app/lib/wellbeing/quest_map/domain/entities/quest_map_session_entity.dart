import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión completada de la técnica 5-4-3-2-1
/// Grounding sensorial para reducir ansiedad
class QuestMapSessionEntity extends Equatable {
  final String? id;
  final String userId;
  final DateTime completedAt;

  // 5 cosas que ves
  final List<String> sightAnswers;

  // 4 cosas que tocas
  final List<String> touchAnswers;

  // 3 cosas que oyes
  final List<String> soundAnswers;

  // 2 cosas que hueles
  final List<String> smellAnswers;

  // 1 cosa que saboreas
  final List<String> tasteAnswers;

  final int durationSeconds;

  const QuestMapSessionEntity({
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

  /// Verifica si la sesión está completa (todas las respuestas)
  bool get isComplete {
    return sightAnswers.length == 5 &&
        touchAnswers.length == 4 &&
        soundAnswers.length == 3 &&
        smellAnswers.length == 2 &&
        tasteAnswers.length == 1;
  }

  /// Total de respuestas ingresadas
  int get totalAnswers {
    return sightAnswers.length +
        touchAnswers.length +
        soundAnswers.length +
        smellAnswers.length +
        tasteAnswers.length;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        sightAnswers,
        touchAnswers,
        soundAnswers,
        smellAnswers,
        tasteAnswers,
        durationSeconds,
      ];
}
