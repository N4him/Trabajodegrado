import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RegisterRemoteDataSource {
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  });
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  RegisterRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    final result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'Error al crear la cuenta',
      );
    }

    final avatarUrl =
        "https://avatar.iran.liara.run/public/$gender?username=$name";

    await firestore.collection('users').doc(user.uid).set({
      'email': email,
      'displayName': name,
      'photoUrl': avatarUrl,
      'points': 0,
      'level': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'gender': gender,
    });

    return user;
  }
}
