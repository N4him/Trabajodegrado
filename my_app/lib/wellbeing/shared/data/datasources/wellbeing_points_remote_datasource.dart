import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wellbeing_points_model.dart';

/// Interfaz abstracta para el data source de puntos de bienestar
abstract class WellbeingPointsDataSource {
  Future<WellbeingPointsModel?> getPoints(String userId);
  Future<void> savePoints(WellbeingPointsModel points);
  Future<void> incrementPoints(String userId, String activityKey);
}

/// Implementación con Firestore del data source de puntos de bienestar
class WellbeingPointsFirestoreDataSource implements WellbeingPointsDataSource {
  final FirebaseFirestore firestore;

  WellbeingPointsFirestoreDataSource({required this.firestore});

  /// Referencia al documento de puntos: users/{userId}/wellbeingPoints/points
  DocumentReference _getPointsDocRef(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('wellbeingPoints')
        .doc('points');
  }

  /// Obtiene los puntos del usuario
  @override
  Future<WellbeingPointsModel?> getPoints(String userId) async {
    final doc = await _getPointsDocRef(userId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return WellbeingPointsModel.fromMap(data);
  }

  /// Guarda los puntos del usuario
  @override
  Future<void> savePoints(WellbeingPointsModel points) async {
    await _getPointsDocRef(points.userId).set(points.toMap());
  }

  /// Incrementa los puntos del usuario para una actividad específica
  @override
  Future<void> incrementPoints(String userId, String activityKey) async {
    final docRef = _getPointsDocRef(userId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      WellbeingPointsModel currentPoints;

      if (!snapshot.exists) {
        // Primera vez, crear documento
        currentPoints = WellbeingPointsModel(
          userId: userId,
          totalPoints: 0,
          lastCompletedDates: {},
        );
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        currentPoints = WellbeingPointsModel.fromMap(data);
      }

      // Verificar si puede ganar punto hoy
      final entity = currentPoints.toEntity();
      if (!entity.canEarnPointToday(activityKey)) {
        // Ya ganó punto hoy en esta actividad, no hacer nada
        return;
      }

      // Incrementar puntos
      final updatedPoints = currentPoints.copyWithIncrementedPoints(activityKey);
      transaction.set(docRef, updatedPoints.toMap());
    });
  }
}
