// lib/features/login/domain/usecases/login_user.dart
import '../entities/user_entity.dart';
import '../repositories/login_repository.dart';

class LoginUser {
  final LoginRepository repository;

  LoginUser(this.repository);

  Future<UserEntity?> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
