import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class DeleteForumPost {
  final ForumRepository repository;

  DeleteForumPost(this.repository);

  Future<Either<Exception, void>> call(String forumId) {
    return repository.deleteForumPost(forumId);
  }
}