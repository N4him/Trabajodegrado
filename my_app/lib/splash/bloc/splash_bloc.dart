import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/onboarding/onboarding_service.dart';

// Events
abstract class SplashEvent {}

class StartSplash extends SplashEvent {}

// States
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToHome extends SplashState {}

// Bloc
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplash>(_onStartSplash);
  }

  Future<void> _onStartSplash(
    StartSplash event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 1. Verificar si hay un usuario autenticado en Firebase
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Si hay sesión activa, ir directamente a Home
        emit(SplashNavigateToHome());
        return;
      }

      // 2. Si no hay sesión, verificar si es primera vez (onboarding)
      final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

      if (!hasSeenOnboarding) {
        // Primera vez, mostrar onboarding
        emit(SplashNavigateToOnboarding());
      } else {
        // Ya vio onboarding, ir a login
        emit(SplashNavigateToLogin());
      }
    } catch (e) {
      // En caso de error, ir a login por defecto
      emit(SplashNavigateToLogin());
    }
  }
}