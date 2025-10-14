import 'package:equatable/equatable.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class LoadForumPostsEvent extends ForumEvent {}

class SearchForumPostsEvent extends ForumEvent {
  final String query;

  const SearchForumPostsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadUserForumPostsEvent extends ForumEvent {
  final String userId;

  const LoadUserForumPostsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateForumPostEvent extends ForumEvent {
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String category;
  final String categoryColor;

  const CreateForumPostEvent({
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.category,
    required this.categoryColor,
  });

  @override
  List<Object?> get props => [
        title,
        content,
        authorId,
        authorName,
        authorPhotoUrl,
        category,
        categoryColor,
      ];
}

class LikeForumPostEvent extends ForumEvent {
  final String forumId;
  final String userId;
  final bool isLiked;

  const LikeForumPostEvent({
    required this.forumId,
    required this.userId,
    required this.isLiked,
  });

  @override
  List<Object> get props => [forumId, userId, isLiked];
}

class ReplyToForumPostEvent extends ForumEvent {
  final String forumId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;

  const ReplyToForumPostEvent({
    required this.forumId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
  });

  @override
  List<Object?> get props => [
        forumId,
        authorId,
        authorName,
        authorPhotoUrl,
        content,
      ];
}

class DeleteForumPostEvent extends ForumEvent {
  final String forumId;

  const DeleteForumPostEvent(this.forumId);

  @override
  List<Object> get props => [forumId];
}

class LoadForumPostsByCategoryEvent extends ForumEvent {
  final String category;

  const LoadForumPostsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class LoadPopularForumPostsEvent extends ForumEvent {
  const LoadPopularForumPostsEvent();

  @override
  List<Object> get props => [];
}