import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc({required this.profileRepository}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(ProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('Usuario no autenticado.'));
        return;
      }

      final profile = await profileRepository.getProfile(user.uid);

      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('No se encontraron datos del usuario.'));
      }
    } catch (e) {
      emit(ProfileError('Error al cargar datos: $e'));
    }
  }
}
