import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/book_entity.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<BookEntity>>> getBooks();
  Future<Either<Failure, List<BookEntity>>> getBooksByCategory(String category);
  Future<Either<Failure, BookEntity>> getBookById(String id);
  Future<Either<Failure, List<BookEntity>>> searchBooks(String query);
}