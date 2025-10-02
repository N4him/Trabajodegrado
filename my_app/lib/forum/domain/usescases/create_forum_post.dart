import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class CreateForumPost {
  final ForumRepository repository;

  CreateForumPost(this.repository);

  Future<Either<Exception, String>> call({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String category,
    required String categoryColor,
  }) {
    return repository.createForumPost(
      title: title,
      content: content,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      category: category,
      categoryColor: categoryColor,
    );
  }
}