import 'package:firebase_auth/firebase_auth.dart';
import '/services/auth_services.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result?.user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  User? getCurrentUser() {
    return _authService.currentUser;
  }
}
