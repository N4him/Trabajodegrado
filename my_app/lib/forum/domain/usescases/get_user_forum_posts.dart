import 'package:dartz/dartz.dart';
import '../entities/forum_entity.dart';
import '../repositories/forum_repository.dart';

class GetUserForumPosts {
  final ForumRepository repository;

  GetUserForumPosts(this.repository);

  Future<Either<Exception, List<ForumEntity>>> call(String userId) {
    return repository.getUserForumPosts(userId);
  }
}