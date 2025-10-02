import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class LikeForumPost {
  final ForumRepository repository;

  LikeForumPost(this.repository);

  Future<Either<Exception, void>> call({
    required String forumId,
    required String userId,
    required bool isLiked,
  }) {
    if (isLiked) {
      return repository.unlikeForumPost(forumId: forumId, userId: userId);
    } else {
      return repository.likeForumPost(forumId: forumId, userId: userId);
    }
  }
}