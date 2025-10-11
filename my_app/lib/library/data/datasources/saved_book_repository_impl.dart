import 'package:my_app/library/domain/repositories/saved_book_entity.dart';

import '../../domain/entities/saved_book_entity.dart';
import '../datasources/saved_book_remote_datasource.dart';
import '../models/saved_book_model.dart';

class SavedBookRepositoryImpl implements SavedBookRepository {
  final SavedBookRemoteDataSource remoteDataSource;

  SavedBookRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> saveBook(SavedBookEntity book, String userId) async {
    final bookModel = SavedBookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      category: book.category,
      coverUrl: book.coverUrl,
      pages: book.pages,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );
    return remoteDataSource.saveBook(bookModel, userId);
  }

  @override
  Future<List<SavedBookEntity>> getUserSavedBooks(String userId) {
    return remoteDataSource.getUserSavedBooks(userId);
  }

  @override
  Future<SavedBookEntity?> getSavedBook(String bookId, String userId) {
    return remoteDataSource.getSavedBook(bookId, userId);
  }

  @override
  Future<void> deleteSavedBook(String bookId, String userId) {
    return remoteDataSource.deleteSavedBook(bookId, userId);
  }

  @override
  Future<bool> isBookSaved(String bookId, String userId) {
    return remoteDataSource.isBookSaved(bookId, userId);
  }
}
