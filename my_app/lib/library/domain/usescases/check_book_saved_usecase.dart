import 'package:my_app/library/domain/repositories/saved_book_repository.dart';


class CheckBookSavedUseCase {
  final SavedBookRepository repository;

  CheckBookSavedUseCase(this.repository);

  Future<bool> call(String bookId, String userId) {
    return repository.isBookSaved(bookId, userId);
  }
}