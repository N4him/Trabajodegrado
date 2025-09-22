import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/data/repositories/user_repository.dart';
import 'package:my_app/login/data/auth_repository.dart';
import 'splash/bloc/splash_bloc.dart';
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'login/blocs/login_bloc.dart';
import 'login/presentation/login_screen.dart';
import 'register/presentation/register_screen.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.authStateChanges().listen((user) {
    // Aquí puedes manejar cambios de autenticación si es necesario
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => UserRepository(),
      child: MaterialApp(
        title: 'Flutter BLoC App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocProvider(
          create: (context) => SplashBloc()..add(StartSplash()),
          child: SplashScreen(),
        ),
        routes: {
          '/onboarding': (context) => OnboardingScreen(),
          '/login': (context) => BlocProvider(
                create: (context) => LoginBloc(authRepository: AuthRepository()),
                child: LoginScreen(),
              ),
          '/home': (context) => HomeScreen(),
          '/register': (context) => RegisterScreen(),
          '/library': (context) => LibraryScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}