import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stop_session_model.dart';

/// Interfaz abstracta para el data source remoto de sesiones de STOP
abstract class StopGameDataSource {
  Future<void> saveSession(StopSessionModel session);
  Future<List<StopSessionModel>> fetchSessionsByUserId(String userId);
  Future<List<StopSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// Implementación con Firestore del data source de sesiones de STOP
class StopGameFirestoreDataSource implements StopGameDataSource {
  final FirebaseFirestore firestore;

  StopGameFirestoreDataSource({required this.firestore});

  /// Ruta: users/{userId}/stopSessions/{sessionId}
  CollectionReference _getSessionsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('stopSessions');
  }

  @override
  Future<void> saveSession(StopSessionModel session) async {
    await _getSessionsCollection(session.userId).add(session.toMap());
  }

  @override
  Future<List<StopSessionModel>> fetchSessionsByUserId(String userId) async {
    final querySnapshot = await _getSessionsCollection(userId)
        .orderBy('completedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => StopSessionModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StopSessionModel>> fetchSessionsByDateRange(
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
        .map((doc) => StopSessionModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
