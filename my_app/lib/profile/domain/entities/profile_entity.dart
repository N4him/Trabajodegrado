import 'package:my_app/register/domain/entities/user_entity.dart';

class ProfileEntity extends UserEntity {
  final String? photoUrl;
  final int? points;
  final int? level;

  ProfileEntity({
    required String uid,
    required String email,
    required String name,
    String? gender, // Hacerlo opcional
    this.photoUrl,
    this.points,
    this.level,
  }) : super(
    uid: uid, 
    email: email, 
    name: name, 
    gender: gender ?? '' // Proporcionar valor por defecto
  );

  // Método para crear copia con cambios
  ProfileEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? gender,
    String? photoUrl,
    int? points,
    int? level,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      level: level ?? this.level,
    );
  }

  @override
  String toString() {
    return 'ProfileEntity{uid: $uid, email: $email, name: $name, gender: $gender, photoUrl: $photoUrl, points: $points, level: $level}';
  }
}