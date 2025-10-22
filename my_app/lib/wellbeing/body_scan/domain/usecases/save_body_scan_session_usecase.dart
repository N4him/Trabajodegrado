import 'package:dartz/dartz.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/usescases/usecase.dart';
import '../entities/body_scan_session_entity.dart';
import '../repositories/body_scan_repository.dart';

/// Caso de uso para guardar una sesión de Body Scan
class SaveBodyScanSessionUseCase implements UseCase<void, BodyScanSessionEntity> {
  final BodyScanRepository repository;

  SaveBodyScanSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(BodyScanSessionEntity params) async {
    return await repository.saveSession(params);
  }
}
