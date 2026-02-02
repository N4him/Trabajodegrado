import 'package:dartz/dartz.dart';
import 'package:my_app/core/di/error/exceptions.dart';
import 'package:my_app/core/failures/failures.dart';
import 'package:my_app/library/data/models/reading_progress_model.dart';
import 'package:my_app/library/domain/entities/reading_progress_entity.dart';
import 'package:my_app/library/domain/repositories/reading_progress_repository.dart';

import '../datasources/reading_progress_remote_datasource.dart';

class ReadingProgressRepositoryImpl implements ReadingProgressRepository {
  final ReadingProgressRemoteDataSource remoteDataSource;

  ReadingProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveProgress(
      ReadingProgressEntity progress) async {
    try {
      // Obtener el progreso anterior para verificar si se completó
      final previousProgress = await remoteDataSource.getProgress(
        progress.bookId,
        progress.userId,
      );

      // Guardar el nuevo progreso
      await remoteDataSource.saveProgress(progress as ReadingProgressModel);

      // Verificar si el libro acaba de completarse
      final wasNotCompleted = previousProgress == null || 
          previousProgress.currentPage < previousProgress.totalPages;
      final isNowCompleted = progress.currentPage >= progress.totalPages;

      // Retornar información sobre si se completó el libro
      return Right({
        'success': true,
        'bookCompleted': wasNotCompleted && isNowCompleted,
        'points': wasNotCompleted && isNowCompleted 
            ? _calculateCompletionPoints(progress) 
            : 0,
      });
    } on ServerException {
      return const Left(ServerFailure('Error al guardar el progreso'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  // Calcular puntos basados en el libro
  int _calculateCompletionPoints(ReadingProgressEntity progress) {
    int basePoints = 50; // Puntos base por completar cualquier libro
    
    // Puntos adicionales por número de páginas
    if (progress.totalPages > 500) {
      basePoints += 30; // Libro largo
    } else if (progress.totalPages > 300) {
      basePoints += 20; // Libro mediano
    } else if (progress.totalPages > 100) {
      basePoints += 10; // Libro corto
    }
    
    return basePoints;
  }

  @override
  Future<Either<Failure, ReadingProgressEntity?>> getProgress(
      String bookId, String userId) async {
    try {
      final progress = await remoteDataSource.getProgress(bookId, userId);
      return Right(progress);
    } on ServerException {
      return const Left(ServerFailure('Error al obtener el progreso'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReadingProgressEntity>>> getUserReadingProgress(
      String userId) async {
    try {
      final progressList = await remoteDataSource.getUserReadingProgress(userId);
      return Right(progressList);
    } on ServerException {
      return const Left(ServerFailure('Error al cargar el progreso de lectura'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReadingProgressEntity>>> getBooksInProgress(
      String userId) async {
    try {
      final progressList = await remoteDataSource.getBooksInProgress(userId);
      return Right(progressList);
    } on ServerException {
      return const Left(ServerFailure('Error al cargar libros en progreso'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReadingProgressEntity>>> getCompletedBooks(
      String userId) async {
    try {
      final progressList = await remoteDataSource.getCompletedBooks(userId);
      return Right(progressList);
    } on ServerException {
      return const Left(ServerFailure('Error al cargar libros completados'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProgress(
      String bookId, String userId) async {
    try {
      await remoteDataSource.deleteProgress(bookId, userId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure('Error al eliminar el progreso'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, ReadingProgressEntity?>> watchProgress(
      String bookId, String userId) {
    try {
      return remoteDataSource.watchProgress(bookId, userId).map(
        (progress) => Right(progress),
      );
    } on ServerException {
      return Stream.value(
        const Left(ServerFailure('Error al escuchar el progreso')),
      );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Error inesperado: ${e.toString()}')),
      );
    }
  }
}