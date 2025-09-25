import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class RegisterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}
class RegisterLoading extends RegisterState {}
class RegisterSuccess extends RegisterState {
  final UserEntity user;

  RegisterSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}
class RegisterFailure extends RegisterState {
  final String error;

  RegisterFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
