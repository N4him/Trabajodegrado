import 'package:dartz/dartz.dart';
import '../../domain/entities/forum_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../../domain/repositories/forum_repository.dart';
import '../datasources/forum_remote_data_source.dart';

class ForumRepositoryImpl implements ForumRepository {
  final ForumRemoteDataSource remoteDataSource;

  ForumRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, String>> createForumPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String category,
    required String categoryColor,
  }) async {
    try {
      final forumId = await remoteDataSource.createForumPost(
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        category: category,
        categoryColor: categoryColor,
      );
      return Right(forumId);
    } catch (e) {
      return Left(Exception('Error creating forum post: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ForumEntity>>> getForumPosts() async {
    try {
      final posts = await remoteDataSource.getForumPosts();
      return Right(posts);
    } catch (e) {
      return Left(Exception('Error getting forum posts: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> likeForumPost({
    required String forumId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.likeForumPost(forumId: forumId, userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error liking forum post: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> unlikeForumPost({
    required String forumId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.unlikeForumPost(forumId: forumId, userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error unliking forum post: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> replyForumPost({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    try {
      final replyId = await remoteDataSource.replyForumPost(
        forumId: forumId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
      );
      return Right(replyId);
    } catch (e) {
      return Left(Exception('Error replying to forum post: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ReplyEntity>>> getForumReplies(
      String forumId) async {
    try {
      final replies = await remoteDataSource.getForumReplies(forumId);
      return Right(replies);
    } catch (e) {
      return Left(Exception('Error getting forum replies: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteForumPost(String forumId) async {
    try {
      await remoteDataSource.deleteForumPost(forumId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error deleting forum post: $e'));
    }
  }
}