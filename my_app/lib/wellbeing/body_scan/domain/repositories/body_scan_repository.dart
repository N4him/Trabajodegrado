import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../entities/body_scan_session_entity.dart';

/// Repositorio abstracto para Body Scan Sessions
abstract class BodyScanRepository {
  Future<Either<Failure, void>> saveSession(BodyScanSessionEntity session);
  Future<Either<Failure, List<BodyScanSessionEntity>>> getSessionsByUserId(String userId);
  Future<Either<Failure, List<BodyScanSessionEntity>>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
