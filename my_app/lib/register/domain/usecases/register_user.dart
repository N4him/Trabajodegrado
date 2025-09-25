import '../entities/user_entity.dart';
import '../repositories/register_repository.dart';

class RegisterUser {
  final RegisterRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity?> execute({
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name,
      gender: gender,
    );
  }
}
