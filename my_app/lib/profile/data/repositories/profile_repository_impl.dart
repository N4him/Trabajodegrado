import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    try {
      // Primero intentar obtener desde Firestore
      final doc = await _firestore.collection('users').doc(uid).get();
      
      // Si no existe en Firestore, crear uno basado en FirebaseAuth
      if (!doc.exists) {
        final user = _auth.currentUser;
        if (user != null && user.uid == uid) {
          // Crear perfil inicial en Firestore basado en FirebaseAuth
          final initialProfile = ProfileEntity(
            uid: uid,
            email: user.email ?? '',
            name: user.displayName ?? 'Usuario',
            gender: null,
            photoUrl: user.photoURL,
            points: 0,
            level: 1,
          );
          
          // Guardarlo en Firestore
          await _createInitialProfile(initialProfile);
          return initialProfile;
        }
        return null;
      }

      // Si existe en Firestore, obtener los datos
      final data = doc.data()!;
      return ProfileEntity(
        uid: uid,
        email: data['email'] ?? '',
        name: data['displayName'] ?? data['name'] ?? 'Usuario',
        gender: data['gender'],
        photoUrl: data['photoUrl'],
        points: data['points'] ?? 0,
        level: data['level'] ?? 1,
      );
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      final updateData = <String, dynamic>{
        'displayName': profile.name,
        'email': profile.email,
      };

      // Solo agregar campos que no son null
      if (profile.photoUrl != null) {
        updateData['photoUrl'] = profile.photoUrl;
      }
      if (profile.gender != null) {
        updateData['gender'] = profile.gender;
      }
      if (profile.points != null) {
        updateData['points'] = profile.points;
      }
      if (profile.level != null) {
        updateData['level'] = profile.level;
      }

      // Agregar timestamp de última actualización
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(profile.uid).set(
        updateData,
        SetOptions(merge: true), // Usar merge para no sobrescribir campos existentes
      );

      print('Profile updated successfully in Firestore');
    } catch (e) {
      print('Error updating profile in Firestore: $e');
      throw e;
    }
  }

  // Método privado para crear perfil inicial
  Future<void> _createInitialProfile(ProfileEntity profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).set({
        'uid': profile.uid,
        'email': profile.email,
        'displayName': profile.name,
        'photoUrl': profile.photoUrl,
        'gender': profile.gender,
        'points': profile.points ?? 0,
        'level': profile.level ?? 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Initial profile created in Firestore');
    } catch (e) {
      print('Error creating initial profile: $e');
      throw e;
    }
  }
}