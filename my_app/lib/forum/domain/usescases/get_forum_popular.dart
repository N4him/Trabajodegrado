import 'package:dartz/dartz.dart';
import 'package:my_app/forum/domain/entities/forum_entity.dart';
import 'package:my_app/forum/domain/repositories/forum_repository.dart';

class GetPopularForumPosts  {
  final ForumRepository repository;

  GetPopularForumPosts(this.repository);

  Future<Either<Exception, List<ForumEntity>>> call() {
    return repository.getPopularForumPosts();
  }
}