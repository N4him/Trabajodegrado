import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/data/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc({required this.userRepository}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(ProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final data = await userRepository.getUserData(user.uid);
        if (data != null && data.exists) {
          emit(ProfileLoaded(data.data()!));
        } else {
          emit(ProfileError('No se encontraron datos del usuario.'));
        }
      } else {
        emit(ProfileError('Usuario no autenticado.'));
      }
    } catch (e) {
      emit(ProfileError('Error al cargar datos: $e'));
    }
  }
}
