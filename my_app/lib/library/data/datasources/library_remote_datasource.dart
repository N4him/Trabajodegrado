import '../models/book_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<BookModel>> getBooks();
  Future<List<BookModel>> getBooksByCategory(String category);
  Future<BookModel> getBookById(String id);
  Future<List<BookModel>> searchBooks(String query);
}