// lib/features/login/domain/repositories/login_repository.dart
import '../entities/user_entity.dart';

abstract class LoginRepository {
  Future<UserEntity?> login({required String email, required String password});
}
