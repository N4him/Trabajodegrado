import 'package:dartz/dartz.dart';
import '../entities/forum_entity.dart';
import '../repositories/forum_repository.dart';

class SearchForumPosts {
  final ForumRepository repository;

  SearchForumPosts(this.repository);

  Future<Either<Exception, List<ForumEntity>>> call(String query) {
    return repository.searchForumPostsByTitle(query);
  }
}