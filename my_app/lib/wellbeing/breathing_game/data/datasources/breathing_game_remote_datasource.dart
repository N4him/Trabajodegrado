import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/breathing_session_model.dart';

/// Interfaz abstracta para el data source remoto de sesiones de respiración
abstract class BreathingGameDataSource {
  Future<void> saveSession(BreathingSessionModel session);
  Future<List<BreathingSessionModel>> fetchSessionsByUserId(String userId);
  Future<List<BreathingSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// Implementación con Firestore del data source de sesiones de respiración
class BreathingGameFirestoreDataSource implements BreathingGameDataSource {
  final FirebaseFirestore firestore;

  BreathingGameFirestoreDataSource({required this.firestore});

  /// Ruta: users/{userId}/breathingSessions/{sessionId}
  CollectionReference _getSessionsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('breathingSessions');
  }

  @override
  Future<void> saveSession(BreathingSessionModel session) async {
    await _getSessionsCollection(session.userId).add(session.toMap());
  }

  @override
  Future<List<BreathingSessionModel>> fetchSessionsByUserId(String userId) async {
    final querySnapshot = await _getSessionsCollection(userId)
        .orderBy('completedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => BreathingSessionModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BreathingSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final querySnapshot = await _getSessionsCollection(userId)
        .where('completedAt', isGreaterThanOrEqualTo: startStr)
        .where('completedAt', isLessThanOrEqualTo: endStr)
        .orderBy('completedAt', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => BreathingSessionModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
