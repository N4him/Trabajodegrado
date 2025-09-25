import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_user.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUser registerUser;

  RegisterBloc({required this.registerUser}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());

    try {
      final user = await registerUser.execute(
        email: event.email,
        password: event.password,
        name: event.name,
        gender: event.gender,
      );

      if (user != null) {
        emit(RegisterSuccess(user: user));
      } else {
        emit(RegisterFailure(error: 'No se pudo crear el usuario'));
      }
    } catch (e) {
      emit(RegisterFailure(error: e.toString()));
    }
  }
}
