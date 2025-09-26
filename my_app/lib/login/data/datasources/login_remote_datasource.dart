// lib/features/login/data/datasources/login_remote_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginRemoteDataSource {
  Future<User> login({required String email, required String password});
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  LoginRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user!;
    } on FirebaseAuthException catch (e) {
      // 👇 relanzamos el error para que el Bloc lo pueda mapear
      throw e;
    }
  }
}
