// lib/features/login/presentation/bloc/login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user =
          await loginUser(email: event.email, password: event.password);
      if (user != null) {
        emit(LoginSuccess(user: user));
      } else {
        emit(LoginFailure(error: 'Error al iniciar sesión'));
      }
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }
}
