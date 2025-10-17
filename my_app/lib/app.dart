import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/presentation/bloc/forum_bloc.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';
import 'package:my_app/habits/presentation/blocs/habit_bloc.dart'; 

import 'core/di/injector.dart';
import 'config/app_router.dart';

import 'splash/bloc/splash_bloc.dart';
import 'login/presentation/blocs/login_bloc.dart';
import 'register/presentation/blocs/register_bloc.dart';
import 'profile/presentation/bloc/profile_bloc.dart';

import 'login/domain/usecases/login_user.dart';
import 'register/domain/usecases/register_user.dart';
import 'profile/domain/repositories/profile_repository.dart';

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
          BlocProvider<LibraryBloc>(
            create: (_) => LibraryBloc(
              getBooks: getIt<GetBooks>(),
              getBooksByCategory: getIt<GetBooksByCategory>(),
              searchBooks: getIt<SearchBooks>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(profileRepository: getIt<ProfileRepository>()),
          ),
          BlocProvider<ForumBloc>(
            create: (_) => getIt<ForumBloc>(),
          ),
          BlocProvider<HabitBloc>(
            create: (_) => getIt<HabitBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter BLoC App',
          theme: ThemeData.light(useMaterial3: true).copyWith(
            primaryColor: const Color(0xFF6C63FF),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              secondary: Color(0xFF5E35B1),
              surface: Colors.white,
              background: Color.fromARGB(255, 235, 233, 243),
            ),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            primaryColor: const Color(0xFF6C63FF),
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2C3E50),
              foregroundColor: Color.fromARGB(255, 241, 143, 143),
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C6CFF),
              secondary: Color(0xFF6C63FF),
              surface: Color(0xFF2C3E50),
              background: Color(0xFF1A1A2E),
            ),
          ),
          themeMode: ThemeMode.system, // Sigue el tema del sistema por defecto
          initialRoute: AppRouter.splash,
          routes: AppRouter.routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}