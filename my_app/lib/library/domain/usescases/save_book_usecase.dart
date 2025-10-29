import 'package:my_app/library/domain/repositories/saved_book_repository.dart';

import '../entities/saved_book_entity.dart';

class SaveBookUseCase {
  final SavedBookRepository repository;

  SaveBookUseCase(this.repository);

  Future<void> call(SavedBookEntity book, String userId) async {
    return await repository.saveBook(book, userId);
  }
}