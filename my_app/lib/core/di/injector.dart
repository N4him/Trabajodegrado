import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../login/data/datasources/login_remote_datasource.dart';
import '../../login/data/repositories/login_repository_impl.dart';
import '../../login/domain/repositories/login_repository.dart';
import '../../login/domain/usecases/login_user.dart';

import '../../register/data/datasources/register_remote_datasource.dart';
import '../../register/data/repositories/register_repository_impl.dart';
import '../../register/domain/repositories/register_repository.dart';
import '../../register/domain/usecases/register_user.dart';

import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../profile/domain/repositories/profile_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Sources
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(firebaseAuth: getIt()),
  );
  getIt.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<LoginUser>(() => LoginUser(getIt()));
  getIt.registerLazySingleton<RegisterUser>(() => RegisterUser(getIt()));
}
