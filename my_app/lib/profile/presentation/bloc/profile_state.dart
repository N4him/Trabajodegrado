// profile_state.dart
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  ProfileLoaded(this.profile);
}

class ProfileUpdating extends ProfileState {
  final ProfileEntity profile;

  ProfileUpdating(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}