import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import 'package:my_app/core/usescases/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/library_repository.dart';

class SearchBooks implements UseCase<List<BookEntity>, String> {
  final LibraryRepository repository;

  SearchBooks(this.repository);

  @override
  Future<Either<Failure, List<BookEntity>>> call(String params) async {
    if (params.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchBooks(params.trim());
  }
}