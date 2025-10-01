import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:my_app/library/domain/usescases/get_books.dart';
import 'package:my_app/library/domain/usescases/get_books_by_category.dart';
import 'package:my_app/library/domain/usescases/search_books.dart';
import 'package:my_app/library/presentation/blocs/library_bloc.dart';

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
  final AdaptiveThemeMode? savedThemeMode;
  
  const MyApp({super.key, this.savedThemeMode});

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
        ],
        child: AdaptiveTheme(
          light: ThemeData.light(useMaterial3: true).copyWith(
            primaryColor: const Color(0xFF6C63FF),
    scaffoldBackgroundColor: Colors.transparent, // 👈 evita blanco global
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              secondary: Color(0xFF5E35B1),
              surface: Colors.white,
              background: Color(0xFFF8F9FA),
            ),
          ),
          dark: ThemeData.dark(useMaterial3: true).copyWith(
            primaryColor: const Color(0xFF6C63FF),
                scaffoldBackgroundColor: Colors.transparent, // 👈 evita blanco global

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C6CFF),
              secondary: Color(0xFF6C63FF),
              surface: Color(0xFF1E1E1E),
              background: Color(0xFF121212),
            ),
          ),
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => MaterialApp(
            title: 'Flutter BLoC App',
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: AppRouter.splash,
            routes: AppRouter.routes,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}