import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_services.dart';

class RegisterRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  RegisterRepository({
    AuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String gender, // 👈 obligatorio
  }) async {
    final result = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    final user = result?.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'Error al crear la cuenta',
      );
    }

    // 👇 Aquí generamos automáticamente la URL
    final avatarUrl =
        "https://avatar.iran.liara.run/public/$gender?username=$displayName";

    await _saveUserDataToFirestore(
      userId: user.uid,
      email: email,
      displayName: displayName,
      photoUrl: avatarUrl,
      gender: gender,
    );

    return user;
  }

  Future<void> _saveUserDataToFirestore({
    required String userId,
    required String email,
    required String displayName,
    required String photoUrl,
    required String gender,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'points': 0,
        'level': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'gender': gender,
      });
    } catch (e) {
      await _cleanupAuthUser();
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error al guardar datos del usuario: $e',
      );
    }
  }

  Future<void> _cleanupAuthUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.delete();
    } catch (e) {
      print('Error cleaning up auth user: $e');
    }
  }
}
