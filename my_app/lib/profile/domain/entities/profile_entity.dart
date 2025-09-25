import 'package:my_app/register/domain/entities/user_entity.dart';

class ProfileEntity extends UserEntity {
  final String? photoUrl;
  final int? points;
  final int? level;

  ProfileEntity({
    required String uid,
    required String email,
    required String name,
    required String gender,
    this.photoUrl,
    this.points,
    this.level,
  }) : super(uid: uid, email: email, name: name, gender: gender);
}
