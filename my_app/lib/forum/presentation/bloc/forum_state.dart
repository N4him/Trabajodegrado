import 'package:equatable/equatable.dart';
import '../../domain/entities/forum_entity.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {}

class ForumLoading extends ForumState {}

class ForumLoaded extends ForumState {
  final List<ForumEntity> posts;

  const ForumLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class ForumError extends ForumState {
  final String message;

  const ForumError(this.message);

  @override
  List<Object> get props => [message];
}

class ForumPostCreated extends ForumState {
  final String forumId;

  const ForumPostCreated(this.forumId);

  @override
  List<Object> get props => [forumId];
}

class ForumPostLiked extends ForumState {}

class ForumPostReplied extends ForumState {
  final String replyId;

  const ForumPostReplied(this.replyId);

  @override
  List<Object> get props => [replyId];
}

class ForumPostDeleted extends ForumState {}
