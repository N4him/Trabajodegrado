import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/body_scan_session_model.dart';

/// Interfaz abstracta para el data source de Body Scan
abstract class BodyScanDataSource {
  Future<void> saveSession(BodyScanSessionModel session);
  Future<List<BodyScanSessionModel>> fetchSessionsByUserId(String userId);
  Future<List<BodyScanSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// Implementación con Firestore del data source de Body Scan
class BodyScanFirestoreDataSource implements BodyScanDataSource {
  final FirebaseFirestore firestore;

  BodyScanFirestoreDataSource({required this.firestore});

  /// Referencia a la colección: users/{userId}/bodyScanSessions
  CollectionReference _getSessionsCollectionRef(String userId) {
    return firestore.collection('users').doc(userId).collection('bodyScanSessions');
  }

  /// Guarda una sesión en Firestore
  @override
  Future<void> saveSession(BodyScanSessionModel session) async {
    final ref = _getSessionsCollectionRef(session.userId);
    await ref
        .doc(session.id.isEmpty ? null : session.id)
        .set(session.toMap());
  }

  /// Obtiene todas las sesiones de un usuario
  @override
  Future<List<BodyScanSessionModel>> fetchSessionsByUserId(String userId) async {
    final snapshot = await _getSessionsCollectionRef(userId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return BodyScanSessionModel.fromMap(data, doc.id);
        })
        .whereType<BodyScanSessionModel>()
        .toList();
  }

  /// Obtiene sesiones de un usuario en un rango de fechas
  @override
  Future<List<BodyScanSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _getSessionsCollectionRef(userId)
        .where('completedAt',
            isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('completedAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          return BodyScanSessionModel.fromMap(data, doc.id);
        })
        .whereType<BodyScanSessionModel>()
        .toList();
  }
}
