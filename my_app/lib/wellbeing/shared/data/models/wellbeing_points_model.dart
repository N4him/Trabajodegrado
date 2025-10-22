import '../../domain/entities/wellbeing_points_entity.dart';

/// Modelo de datos para puntos de bienestar (se guarda en Firestore)
class WellbeingPointsModel {
  final String userId;
  final int totalPoints;
  final Map<String, String> lastCompletedDates;

  WellbeingPointsModel({
    required this.userId,
    required this.totalPoints,
    required this.lastCompletedDates,
  });

  /// Convierte la Entidad del Dominio a un Modelo
  factory WellbeingPointsModel.fromEntity(WellbeingPointsEntity entity) {
    return WellbeingPointsModel(
      userId: entity.userId,
      totalPoints: entity.totalPoints,
      lastCompletedDates: entity.lastCompletedDates,
    );
  }

  /// Convierte el Modelo a un Map<String, dynamic> (Para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'lastCompletedDates': lastCompletedDates,
    };
  }

  /// Crea un Modelo a partir de un Map (Para leer de Firestore)
  factory WellbeingPointsModel.fromMap(Map<String, dynamic> map) {
    return WellbeingPointsModel(
      userId: map['userId'] as String,
      totalPoints: map['totalPoints'] as int? ?? 0,
      lastCompletedDates: Map<String, String>.from(
        map['lastCompletedDates'] as Map<dynamic, dynamic>? ?? {},
      ),
    );
  }

  /// Convierte el Modelo de vuelta a la Entidad (Para devolver al Dominio)
  WellbeingPointsEntity toEntity() {
    return WellbeingPointsEntity(
      userId: userId,
      totalPoints: totalPoints,
      lastCompletedDates: lastCompletedDates,
    );
  }

  /// Crea un nuevo modelo con puntos incrementados
  WellbeingPointsModel copyWithIncrementedPoints(String activityKey) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final updatedDates = Map<String, String>.from(lastCompletedDates);
    updatedDates[activityKey] = today;

    return WellbeingPointsModel(
      userId: userId,
      totalPoints: totalPoints + 1,
      lastCompletedDates: updatedDates,
    );
  }
}
