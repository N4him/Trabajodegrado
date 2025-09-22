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

    await _saveUserDataToFirestore(
      userId: user.uid,
      email: email,
      displayName: displayName,
    );

    return user;
  }

  Future<void> _saveUserDataToFirestore({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'points': 0,
        'level': 1,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
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
