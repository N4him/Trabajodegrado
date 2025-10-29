import 'package:dartz/dartz.dart';
import 'package:my_app/core/failures/failures.dart';
import '../entities/reading_progress_entity.dart';
import '../repositories/reading_progress_repository.dart';

class SaveReadingProgressUseCase {
  final ReadingProgressRepository repository;

  SaveReadingProgressUseCase(this.repository);

  Future<Either<Failure, void>> call(ReadingProgressEntity progress) async {
    return await repository.saveProgress(progress);
  }
}