import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import 'package:my_app/core/usescases/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/library_repository.dart';


class GetBookById implements UseCase<BookEntity, String> {
  final LibraryRepository repository;

  GetBookById(this.repository);

  @override
  Future<Either<Failure, BookEntity>> call(String params) async {
    return await repository.getBookById(params);
  }
}