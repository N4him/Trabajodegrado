// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Login imports
import '../../login/data/datasources/login_remote_datasource.dart';
import '../../login/data/repositories/login_repository_impl.dart';
import '../../login/domain/repositories/login_repository.dart';
import '../../login/domain/usecases/login_user.dart';
import '../../login/presentation/blocs/login_bloc.dart';

// Register imports
import '../../register/data/datasources/register_remote_datasource.dart';
import '../../register/data/repositories/register_repository_impl.dart';
import '../../register/domain/repositories/register_repository.dart';
import '../../register/domain/usecases/register_user.dart';
import '../../register/presentation/blocs/register_bloc.dart';

// Profile imports
import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // ==============================================
  // FIREBASE INSTANCES
  // ==============================================
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ==============================================
  // DATA SOURCES
  // ==============================================
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(firebaseAuth: getIt()),
  );
  
  getIt.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );

  // ==============================================
  // REPOSITORIES
  // ==============================================
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

  // ==============================================
  // USE CASES
  // ==============================================
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt()),
  );
  
  getIt.registerLazySingleton<RegisterUser>(
    () => RegisterUser(getIt()),
  );

  // ==============================================
  // BLOCS - FACTORY REGISTRATION
  // ==============================================
  // Los BLoCs se registran como factory porque necesitan ser nuevos cada vez
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(loginUser: getIt()),
  );
  
  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(registerUser: getIt()),
  );
  
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: getIt()),
  );
}

// ==============================================
// HELPER FUNCTIONS PARA OBTENER BLOCS
// ==============================================
// Funciones auxiliares para obtener instancias de BLoCs
LoginBloc getLoginBloc() => getIt<LoginBloc>();
RegisterBloc getRegisterBloc() => getIt<RegisterBloc>();
ProfileBloc getProfileBloc() => getIt<ProfileBloc>();

// ==============================================
// FUNCIÓN PARA LIMPIAR DEPENDENCIAS (OPCIONAL)
// ==============================================
Future<void> resetDI() async {
  await getIt.reset();
}