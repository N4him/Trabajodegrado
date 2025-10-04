import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/forum/domain/usescases/create_forum_post.dart';
import 'package:my_app/forum/domain/usescases/delete_forum_post.dart';
import 'package:my_app/forum/domain/usescases/get_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/get_user_forum_posts.dart';
import 'package:my_app/forum/domain/usescases/like_forum_post.dart';
import 'package:my_app/forum/domain/usescases/reply_forum_post.dart';
import 'package:my_app/forum/domain/usescases/search_forum_posts.dart';

import 'forum_event.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final GetForumPosts getForumPostsUseCase;
  final SearchForumPosts searchForumPostsUseCase;
  final GetUserForumPosts getUserForumPostsUseCase;
  final CreateForumPost createForumPostUseCase;
  final LikeForumPost likeForumPostUseCase;
  final ReplyForumPost replyForumPostUseCase;
  final DeleteForumPost deleteForumPostUseCase;

  ForumBloc({
    required this.getForumPostsUseCase,
    required this.searchForumPostsUseCase,
    required this.getUserForumPostsUseCase,
    required this.createForumPostUseCase,
    required this.likeForumPostUseCase,
    required this.replyForumPostUseCase,
    required this.deleteForumPostUseCase,
  }) : super(ForumInitial()) {
    on<LoadForumPostsEvent>(_onLoadForumPosts);
    on<SearchForumPostsEvent>(_onSearchForumPosts);
    on<LoadUserForumPostsEvent>(_onLoadUserForumPosts);
    on<CreateForumPostEvent>(_onCreateForumPost);
    on<LikeForumPostEvent>(_onLikeForumPost);
    on<ReplyToForumPostEvent>(_onReplyToForumPost);
    on<DeleteForumPostEvent>(_onDeleteForumPost);
  }

  Future<void> _onLoadForumPosts(
    LoadForumPostsEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    final result = await getForumPostsUseCase();
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (posts) => emit(ForumLoaded(posts)),
    );
  }

  Future<void> _onSearchForumPosts(
    SearchForumPostsEvent event,
    Emitter<ForumState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadForumPostsEvent());
      return;
    }

    emit(ForumLoading());
    final result = await searchForumPostsUseCase(event.query);
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (posts) => emit(ForumLoaded(posts)),
    );
  }

  Future<void> _onLoadUserForumPosts(
    LoadUserForumPostsEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    final result = await getUserForumPostsUseCase(event.userId);
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (posts) => emit(ForumLoaded(posts)),
    );
  }

  Future<void> _onCreateForumPost(
    CreateForumPostEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    final result = await createForumPostUseCase(
      title: event.title,
      content: event.content,
      authorId: event.authorId,
      authorName: event.authorName,
      authorPhotoUrl: event.authorPhotoUrl,
      category: event.category,
      categoryColor: event.categoryColor,
    );
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (forumId) {
        emit(ForumPostCreated(forumId));
        add(LoadForumPostsEvent());
      },
    );
  }

  Future<void> _onLikeForumPost(
    LikeForumPostEvent event,
    Emitter<ForumState> emit,
  ) async {
    final result = await likeForumPostUseCase(
      forumId: event.forumId,
      userId: event.userId,
      isLiked: event.isLiked,
    );
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (_) {
        emit(ForumPostLiked());
        add(LoadForumPostsEvent());
      },
    );
  }

  Future<void> _onReplyToForumPost(
    ReplyToForumPostEvent event,
    Emitter<ForumState> emit,
  ) async {
    final result = await replyForumPostUseCase(
      forumId: event.forumId,
      authorId: event.authorId,
      authorName: event.authorName,
      authorPhotoUrl: event.authorPhotoUrl,
      content: event.content,
    );
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (replyId) {
        emit(ForumPostReplied(replyId));
        add(LoadForumPostsEvent());
      },
    );
  }

  Future<void> _onDeleteForumPost(
    DeleteForumPostEvent event,
    Emitter<ForumState> emit,
  ) async {
    final result = await deleteForumPostUseCase(event.forumId);
    result.fold(
      (failure) => emit(ForumError(failure.toString())),
      (_) {
        emit(ForumPostDeleted());
        add(LoadForumPostsEvent());
      },
    );
  }
}