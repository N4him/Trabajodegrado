// lib/features/login/data/repositories/login_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';
import '../models/user_model.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> login({required String email, required String password}) async {
    final user = await remoteDataSource.login(email: email, password: password);
    return UserModel.fromFirebase(user);
  }
}
