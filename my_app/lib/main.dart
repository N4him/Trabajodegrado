import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/profile/data/repositories/profile_repository_impl.dart';
import 'package:my_app/profile/domain/repositories/profile_repository.dart';
import 'package:my_app/profile/presentation/bloc/profile_bloc.dart';

import 'login/domain/repositories/login_repository.dart';
import 'login/presentation/blocs/login_bloc.dart';
import 'login/data/datasources/login_remote_datasource.dart';
import 'login/data/repositories/login_repository_impl.dart';
import 'login/domain/usecases/login_user.dart';
import 'login/presentation/pages/login_screen.dart';

import 'register/domain/repositories/register_repository.dart';
import 'register/presentation/blocs/register_bloc.dart';
import 'register/domain/usecases/register_user.dart';
import 'register/data/datasources/register_remote_datasource.dart';
import 'register/data/repositories/register_repository_impl.dart';
import 'register/presentation/register_screen.dart';

import 'splash/bloc/splash_bloc.dart';
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';

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

  // Use Cases
  getIt.registerLazySingleton<LoginUser>(() => LoginUser(getIt()));
  getIt.registerLazySingleton<RegisterUser>(() => RegisterUser(getIt()));

getIt.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(
    firebaseAuth: getIt<FirebaseAuth>(),
    firestore: getIt<FirebaseFirestore>(),
  ),
);



}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await setupDI();

  // Opcional: escucha cambios de autenticación
  FirebaseAuth.instance.authStateChanges().listen((user) {
    // Aquí puedes manejar cambios de sesión si es necesario
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileRepository>(
          create: (_) => getIt<ProfileRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (_) => SplashBloc()..add(StartSplash()),
          ),
          BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(loginUser: getIt<LoginUser>()),
          ),
          BlocProvider<RegisterBloc>(
            create: (_) => RegisterBloc(registerUser: getIt<RegisterUser>()),
          ),
           BlocProvider<ProfileBloc>(
      create: (_) => ProfileBloc(profileRepository: getIt<ProfileRepository>()),
    ),
        ],
        child: MaterialApp(
          title: 'Flutter BLoC App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: SplashScreen(),
          routes: {
            '/onboarding': (_) => OnboardingScreen(),
            '/login': (_) => LoginScreen(),
            '/home': (_) => HomeScreen(),
            '/register': (_) => RegisterScreen(),
            '/library': (_) => LibraryScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
