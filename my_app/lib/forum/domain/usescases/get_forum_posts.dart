import 'package:dartz/dartz.dart';
import '../entities/forum_entity.dart';
import '../repositories/forum_repository.dart';

class GetForumPosts {
  final ForumRepository repository;

  GetForumPosts(this.repository);

  Future<Either<Exception, List<ForumEntity>>> call() {
    return repository.getForumPosts();
  }
}