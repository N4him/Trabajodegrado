import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/reading_progress_entity.dart';
import '../repositories/reading_progress_repository.dart';

class GetBooksInProgressUseCase {
  final ReadingProgressRepository repository;

  GetBooksInProgressUseCase(this.repository);

  Future<Either<Failure, List<ReadingProgressEntity>>> call(String userId) {
    return repository.getBooksInProgress(userId);
  }
}