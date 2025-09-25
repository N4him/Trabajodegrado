// lib/profile/data/repositories/profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return ProfileEntity(
      uid: uid,
      email: data['email'] ?? '',
      name: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      gender: data['gender'],
      points: data['points'],
      level: data['level'],
    );
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await _firestore.collection('users').doc(profile.uid).update({
      'displayName': profile,
      if (profile.photoUrl != null) 'photoUrl': profile.photoUrl,
      if (profile.gender != null) 'gender': profile.gender,
      if (profile.points != null) 'points': profile.points,
      if (profile.level != null) 'level': profile.level,
    });
  }
}
