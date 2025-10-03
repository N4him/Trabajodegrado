// lib/features/login/presentation/bloc/login_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/di/error/firebase_error_mapper.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../domain/usecases/login_user.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUser loginUser;

  LoginBloc({required this.loginUser}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>((event, emit) => emit(LoginInitial()));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Debug
      
      final user = await loginUser(
        email: event.email,
        password: event.password,
      );

      // Debug
      
      if (user == null) {
        emit(LoginFailure(error: 'Error al iniciar sesión'));
        return;
      }

      emit(LoginSuccess(user: user));
    } on FirebaseAuthException catch (e) {
      // Debug
      
      // Usar el mapeador para convertir el código de error a un mensaje amigable
      final userFriendlyMessage = FirebaseErrorMapper.toMessage(e.code);
      emit(LoginFailure(error: userFriendlyMessage));
      
    } catch (e) {
      // Debug
      emit(LoginFailure(error: 'Ocurrió un error inesperado'));
    }
  }
}