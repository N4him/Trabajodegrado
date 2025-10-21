import '../entities/gamificacion.dart';
import '../entities/modulo_progreso.dart';

abstract class GamificacionRepository {
  Future<Gamificacion> getGamificacionData(String userId);
  Future<void> updateModuloProgress(
    String userId,
    String moduloKey,
    ModuloProgreso progreso,
  );
  Future<void> addEventToHistorial(String userId, int evento);
  Future<void> updateEstadoGeneral(String userId, EstadoGeneral estado);
  Future<void> addInsigniaToUser(String userId, String insigniaId);
  Future<void> createGamificacionIfNotExists(String userId);
}