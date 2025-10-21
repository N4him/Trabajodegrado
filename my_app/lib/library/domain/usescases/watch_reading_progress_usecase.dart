import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/reading_progress_entity.dart';
import '../repositories/reading_progress_repository.dart';

class WatchReadingProgressUseCase {
  final ReadingProgressRepository repository;

  WatchReadingProgressUseCase(this.repository);

  Stream<Either<Failure, ReadingProgressEntity?>> call(String bookId, String userId) {
    return repository.watchProgress(bookId, userId);
  }
}