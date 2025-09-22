import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener usuario actual (de Firebase Auth)
  User? get currentUser => _auth.currentUser;

  /// Obtener datos del usuario desde Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      return null;
    }
  }

  /// Actualizar datos del perfil (nombre, foto, etc.)
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (photoUrl != null) data['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error al actualizar perfil: $e');
      rethrow;
    }
  }

  /// Actualizar puntos del usuario
  Future<void> updatePoints(String uid, int newPoints) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'points': newPoints,
      });
    } catch (e) {
      print('Error al actualizar puntos: $e');
      rethrow;
    }
  }

  /// Actualizar nivel del usuario
  Future<void> updateLevel(String uid, int newLevel) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'level': newLevel,
      });
    } catch (e) {
      print('Error al actualizar nivel: $e');
      rethrow;
    }
  }
}
