import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/register/data/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository _repository;

  RegisterBloc({required RegisterRepository repository})
      : _repository = repository,
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());

    try {
      final user = await _repository.registerUser(
        email: event.email,
        password: event.password,
        displayName: event.name,
      );
      emit(RegisterSuccess(user: user));
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(error: _getAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      emit(RegisterFailure(error: 'Error al guardar datos: ${e.message}'));
    } catch (e) {
      emit(RegisterFailure(error: e.toString()));
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Esta dirección de correo ya está registrada';
      case 'invalid-email':
        return 'La dirección de correo no es válida';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'operation-not-allowed':
        return 'El registro con email/password no está habilitado';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Error al crear la cuenta: $errorCode';
    }
  }
}
