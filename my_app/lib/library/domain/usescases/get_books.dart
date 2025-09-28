import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import 'package:my_app/core/usescases/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/library_repository.dart';


class GetBooks implements UseCase<List<BookEntity>, NoParams> {
  final LibraryRepository repository;

  GetBooks(this.repository);

  @override
  Future<Either<Failure, List<BookEntity>>> call(NoParams params) async {
    return await repository.getBooks();
  }
}