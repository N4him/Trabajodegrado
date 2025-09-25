import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String password;
  final String name;
  final String gender;

  RegisterSubmitted({
    required this.email,
    required this.password,
    required this.name,
    required this.gender,
  });

  @override
  List<Object?> get props => [email, password, name];
}
