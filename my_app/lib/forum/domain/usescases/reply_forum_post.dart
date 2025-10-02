import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class ReplyForumPost {
  final ForumRepository repository;

  ReplyForumPost(this.repository);

  Future<Either<Exception, String>> call({
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) {
    return repository.replyForumPost(
      forumId: forumId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content,
    );
  }
}