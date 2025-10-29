import '../entities/saved_book_entity.dart';

abstract class SavedBookRepository {
  Future<void> saveBook(SavedBookEntity book, String userId);
  Future<List<SavedBookEntity>> getUserSavedBooks(String userId);
  Future<SavedBookEntity?> getSavedBook(String bookId, String userId);
  Future<void> deleteSavedBook(String bookId, String userId);
  Future<bool> isBookSaved(String bookId, String userId);
}