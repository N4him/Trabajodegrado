// lib/features/login/presentation/bloc/login_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart'; // <-- usar entidad

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user; // <-- cambiar a UserEntity

  LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
