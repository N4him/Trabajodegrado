import 'package:dartz/dartz.dart';
import 'package:my_app/core/di/error/exceptions.dart';
import 'package:my_app/core/failures/failures.dart';

import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';


class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BookEntity>>> getBooks() async {
    try {
      final books = await remoteDataSource.getBooks();
      return Right(books);
    } on ServerException {
      return const Left(ServerFailure('Error al obtener los libros'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getBooksByCategory(
      String category) async {
    try {
      final books = await remoteDataSource.getBooksByCategory(category);
      return Right(books);
    } on ServerException {
      return const Left(ServerFailure('Error al obtener libros por categoría'));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> getBookById(String id) async {
    try {
      final book = await remoteDataSource.getBookById(id);
      return Right(book);
    } on ServerException {
      return const Left(ServerFailure('Error al obtener el libro'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> searchBooks(String query) async {
    try {
      final books = await remoteDataSource.searchBooks(query);
      return Right(books);
    } on ServerException {
      return const Left(ServerFailure('Error al buscar libros'));
    }
  }
}