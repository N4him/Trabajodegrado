import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quest_map_session_model.dart';

/// Data source remoto para Quest Map usando Firestore
abstract class QuestMapDataSource {
  Future<void> saveSession(QuestMapSessionModel session);
  Future<List<QuestMapSessionModel>> fetchSessionsByUserId(String userId);
  Future<List<QuestMapSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

class QuestMapFirestoreDataSource implements QuestMapDataSource {
  final FirebaseFirestore firestore;

  QuestMapFirestoreDataSource({required this.firestore});

  /// Ruta: users/{userId}/questMapSessions/{sessionId}
  CollectionReference _getSessionsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('questMapSessions');
  }

  @override
  Future<void> saveSession(QuestMapSessionModel session) async {
    final collection = _getSessionsCollection(session.userId);
    await collection.add(session.toMap());
  }

  @override
  Future<List<QuestMapSessionModel>> fetchSessionsByUserId(String userId) async {
    final collection = _getSessionsCollection(userId);
    final snapshot = await collection.orderBy('completedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => QuestMapSessionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  @override
  Future<List<QuestMapSessionModel>> fetchSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final collection = _getSessionsCollection(userId);
    final snapshot = await collection
        .where('completedAt',
            isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('completedAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => QuestMapSessionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }
}
