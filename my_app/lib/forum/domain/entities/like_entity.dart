import 'package:equatable/equatable.dart';

class LikeEntity extends Equatable {
  final String userId;
  final DateTime likedAt;

  const LikeEntity({
    required this.userId,
    required this.likedAt,
  });

  @override
  List<Object?> get props => [userId, likedAt];
}