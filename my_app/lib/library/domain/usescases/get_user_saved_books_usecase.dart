import 'package:my_app/library/domain/repositories/saved_book_entity.dart';

import '../entities/saved_book_entity.dart';

class GetUserSavedBooksUseCase {
  final SavedBookRepository repository;

  GetUserSavedBooksUseCase(this.repository);

  Future<List<SavedBookEntity>> call(String userId) {
    return repository.getUserSavedBooks(userId);
  }
}