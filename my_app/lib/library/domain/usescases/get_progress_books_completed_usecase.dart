import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/reading_progress_entity.dart';
import '../repositories/reading_progress_repository.dart';

class GetCompletedBooksUseCase {
  final ReadingProgressRepository repository;

  GetCompletedBooksUseCase(this.repository);

  Future<Either<Failure, List<ReadingProgressEntity>>> call(String userId) {
    return repository.getCompletedBooks(userId);
  }
}