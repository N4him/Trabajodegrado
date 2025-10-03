import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_app/onboarding/onboarding_service.dart';

// Events
abstract class SplashEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartSplash extends SplashEvent {}

// States
abstract class SplashState extends Equatable {
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

// BLoC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplash>(_onStartSplash);
  }

  void _onStartSplash(StartSplash event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    try {
      // Simular carga de la app (inicialización, etc.)
      await Future.delayed(Duration(seconds: 2));
      
      // Verificar si es primera vez
      final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
      
      if (hasSeenOnboarding) {
        emit(SplashNavigateToLogin());
      } else {
        emit(SplashNavigateToOnboarding());
      }
      
    } catch (e) {
      // En caso de error, ir al onboarding para estar seguros
      emit(SplashNavigateToOnboarding());
    }
  }
}