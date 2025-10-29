import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../repositories/reading_progress_repository.dart';

class DeleteReadingProgressUseCase {
  final ReadingProgressRepository repository;

  DeleteReadingProgressUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookId, String userId) {
    return repository.deleteProgress(bookId, userId);
  }
}