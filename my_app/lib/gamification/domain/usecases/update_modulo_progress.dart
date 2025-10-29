import '../entities/modulo_progreso.dart';
import '../repositories/gamificacion_repository.dart';

class UpdateModuloProgress {
  final GamificacionRepository repository;

  UpdateModuloProgress({required this.repository});

  Future<void> call({
    required String userId,
    required String moduloKey,
    required ModuloProgreso progreso,
  }) async {
    // El repositorio ya maneja la lógica de obtener los valores actuales
    // y sumarlos. Solo pasamos el delta (incremento) que queremos agregar.
    await repository.updateModuloProgress(userId, moduloKey, progreso);
  }
}