import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/register_repository.dart';
import '../datasources/register_remote_datasource.dart';
import '../models/user_model.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    final user = await remoteDataSource.register(
      email: email,
      password: password,
      name: name,
      gender: gender,
    );

    if (user == null) return null;

    final userModel = UserModel.fromFirebase(user, name, gender);
    return userModel.toEntity();
  }
}
