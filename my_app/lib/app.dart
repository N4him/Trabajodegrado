import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          initialRoute: AppRouter.splash,
          routes: AppRouter.routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
