import '../../domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String gender;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.gender,
  });

  factory UserModel.fromFirebase(User user, String name, String gender) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
      gender: gender,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      gender: gender,
    );
  }
}
