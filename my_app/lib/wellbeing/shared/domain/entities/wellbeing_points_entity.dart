import 'package:equatable/equatable.dart';

/// Entidad que representa los puntos de bienestar del usuario
class WellbeingPointsEntity extends Equatable {
  final String userId;
  final int totalPoints;

  /// Mapa de actividad -> última fecha completada (YYYY-MM-DD)
  /// Ejemplo: {'body_scan': '2025-10-19', 'breathing_game': '2025-10-18'}
  final Map<String, String> lastCompletedDates;

  const WellbeingPointsEntity({
    required this.userId,
    required this.totalPoints,
    required this.lastCompletedDates,
  });

  /// Verifica si el usuario puede ganar un punto en esta actividad hoy
  bool canEarnPointToday(String activityKey) {
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastDate = lastCompletedDates[activityKey];

    // Si nunca ha completado esta actividad, puede ganar punto
    if (lastDate == null) return true;

    // Si la última fecha es diferente a hoy, puede ganar punto
    return lastDate != today;
  }

  /// Obtiene la fecha de última completación de una actividad
  String? getLastCompletedDate(String activityKey) {
    return lastCompletedDates[activityKey];
  }

  @override
  List<Object?> get props => [userId, totalPoints, lastCompletedDates];
}
