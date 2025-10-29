import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/reading_progress_entity.dart';

abstract class ReadingProgressRepository {
  Future<Either<Failure, void>> saveProgress(ReadingProgressEntity progress);
  Future<Either<Failure, ReadingProgressEntity?>> getProgress(String bookId, String userId);
  Future<Either<Failure, List<ReadingProgressEntity>>> getUserReadingProgress(String userId);
  Future<Either<Failure, List<ReadingProgressEntity>>> getBooksInProgress(String userId);
  Future<Either<Failure, List<ReadingProgressEntity>>> getCompletedBooks(String userId);
  Future<Either<Failure, void>> deleteProgress(String bookId, String userId);
  Stream<Either<Failure, ReadingProgressEntity?>> watchProgress(String bookId, String userId);
}