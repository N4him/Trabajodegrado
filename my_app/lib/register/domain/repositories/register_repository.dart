import '../entities/user_entity.dart';

abstract class RegisterRepository {
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  });
}
