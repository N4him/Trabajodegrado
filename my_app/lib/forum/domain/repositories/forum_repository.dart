import 'package:dartz/dartz.dart';
import '../entities/forum_entity.dart';
import '../entities/reply_entity.dart';

abstract class ForumRepository {
  Future<Either<Exception, String>> createForumPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String category,
    required String categoryColor,
  });

  Future<Either<Exception, List<ForumEntity>>> getForumPosts();

  Future<Either<Exception, void>> likeForumPost({
    required String forumId,
    required String userId,
  });

  Future<Either<Exception, void>> unlikeForumPost({
    required String forumId,
    required String userId,
  });

  Future<Either<Exception, String>> replyForumPost({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  });

  Future<Either<Exception, List<ReplyEntity>>> getForumReplies(String forumId);

  Future<Either<Exception, void>> deleteForumPost(String forumId);
}