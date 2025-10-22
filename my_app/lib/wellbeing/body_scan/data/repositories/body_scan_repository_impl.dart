import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../domain/entities/body_scan_session_entity.dart';
import '../../domain/repositories/body_scan_repository.dart';
import '../datasources/body_scan_remote_datasource.dart';
import '../models/body_scan_session_model.dart';

/// Implementación del repositorio de Body Scan
class BodyScanRepositoryImpl implements BodyScanRepository {
  final BodyScanDataSource dataSource;

  BodyScanRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> saveSession(
      BodyScanSessionEntity session) async {
    try {
      final model = BodyScanSessionModel.fromEntity(session);
      await dataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BodyScanSessionEntity>>> getSessionsByUserId(
      String userId) async {
    try {
      final models = await dataSource.fetchSessionsByUserId(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BodyScanSessionEntity>>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await dataSource.fetchSessionsByDateRange(
        userId,
        startDate,
        endDate,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
