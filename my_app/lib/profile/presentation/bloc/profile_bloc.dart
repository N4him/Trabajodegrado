import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc({required this.profileRepository}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
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
      // Debug
      emit(ProfileError('Error al cargar datos: $e'));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      // Obtener el perfil actual antes de emitir ProfileUpdating
      ProfileEntity? currentProfile;
      if (state is ProfileLoaded) {
        currentProfile = (state as ProfileLoaded).profile;
        emit(ProfileUpdating(currentProfile));
      } else {
        emit(ProfileLoading());
        // Si no tenemos el perfil actual, lo cargamos
        final user = _auth.currentUser;
        if (user == null) {
          emit(ProfileError('Usuario no autenticado.'));
          return;
        }
        currentProfile = await profileRepository.getProfile(user.uid);
        if (currentProfile == null) {
          emit(ProfileError('No se encontraron datos del perfil actual.'));
          return;
        }
        emit(ProfileUpdating(currentProfile));
      }

      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('Usuario no autenticado.'));
        return;
      }

      // Debug

      // Crear el perfil actualizado manteniendo los datos existentes
      final updatedProfile = currentProfile.copyWith(
        name: event.name,
        photoUrl: event.photoUrl.isNotEmpty ? event.photoUrl : null,
      );

      // Debug

      // Actualizar en Firestore primero
      await profileRepository.updateProfile(updatedProfile);
      // Debug

      // Actualizar displayName y photoURL en FirebaseAuth para mantener consistencia
      if (user.displayName != event.name) {
        await user.updateDisplayName(event.name);
        // Debug
      }
      
      if (user.photoURL != event.photoUrl) {
        await user.updatePhotoURL(event.photoUrl.isNotEmpty ? event.photoUrl : null);
        // Debug
      }

      // Actualizar contraseña si se proporcionó una nueva
      if (event.password != null && event.password!.isNotEmpty) {
        await user.updatePassword(event.password!);
        // Debug
      }

      // Recargar los datos del usuario desde Firebase Auth para asegurar consistencia
      await user.reload();
      final refreshedUser = _auth.currentUser;

      // Crear el perfil final con los datos actualizados
      final finalProfile = ProfileEntity(
        uid: refreshedUser?.uid ?? updatedProfile.uid,
        email: refreshedUser?.email ?? updatedProfile.email,
        name: refreshedUser?.displayName ?? updatedProfile.name,
        gender: updatedProfile.gender,
        photoUrl: refreshedUser?.photoURL ?? updatedProfile.photoUrl,
        points: updatedProfile.points,
        level: updatedProfile.level,
      );

      // Debug

      emit(ProfileLoaded(finalProfile));
      
    } catch (e) {
      // Debug
      // Si teníamos un perfil cargado, intentar mantenerlo
      if (state is ProfileUpdating) {
        final profile = (state as ProfileUpdating).profile;
        emit(ProfileLoaded(profile));
        // Luego emitir el error
        await Future.delayed(Duration(milliseconds: 100));
        emit(ProfileError('Error al actualizar perfil: $e'));
      } else if (state is ProfileLoaded) {
        emit(ProfileError('Error al actualizar perfil: $e'));
      } else {
        emit(ProfileError('Error al actualizar perfil: $e'));
      }
    }
  }
}