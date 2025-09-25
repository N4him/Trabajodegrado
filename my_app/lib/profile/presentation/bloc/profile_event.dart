// profile_event.dart
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class RefreshProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? password;
  final String photoUrl;

  UpdateProfile({
    required this.name,
    this.password,
    required this.photoUrl,
  });
}
