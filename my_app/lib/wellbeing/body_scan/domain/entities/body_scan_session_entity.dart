import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión completa de Escaneo Corporal
class BodyScanSessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime completedAt;

  /// Lista de emociones reportadas por cada parte del cuerpo (8 valores: relaxed=true, tense=false)
  final List<bool> emotionReports;

  /// Calificación general de la sesión (1-5)
  final int rating;

  /// Duración total de la sesión en segundos
  final int durationSeconds;

  const BodyScanSessionEntity({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.emotionReports,
    required this.rating,
    required this.durationSeconds,
  });

  /// Calcula el porcentaje de partes relajadas
  double get relaxationPercentage {
    if (emotionReports.isEmpty) return 0.0;
    final relaxedCount = emotionReports.where((e) => e).length;
    return (relaxedCount / emotionReports.length) * 100;
  }

  /// Cuenta cuántas partes estaban relajadas
  int get relaxedPartsCount => emotionReports.where((e) => e).length;

  /// Cuenta cuántas partes estaban tensas
  int get tensePartsCount => emotionReports.where((e) => !e).length;

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        emotionReports,
        rating,
        durationSeconds,
      ];
}
