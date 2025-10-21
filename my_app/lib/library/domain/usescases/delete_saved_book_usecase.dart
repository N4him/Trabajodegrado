import 'package:my_app/library/domain/repositories/saved_book_repository.dart';


class DeleteSavedBookUseCase {
  final SavedBookRepository repository;

  DeleteSavedBookUseCase(this.repository);

  Future<void> call(String bookId, String userId) {
    return repository.deleteSavedBook(bookId, userId);
  }
}