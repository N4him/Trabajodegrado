import '../../domain/entities/gamificacion.dart';
import '../../domain/entities/modulo_progreso.dart';
import '../../domain/repositories/gamificacion_repository.dart';
import '../datasources/gamificacion_remote_data_source.dart';

class GamificacionRepositoryImpl implements GamificacionRepository {
  final GamificacionRemoteDataSource remoteDataSource;

  GamificacionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Gamificacion> getGamificacionData(String userId) async {
    try {
      return await remoteDataSource.getGamificacionData(userId);
    } catch (e) {
      throw Exception('Error en el repositorio al obtener gamificación: $e');
    }
  }

  @override
  Future<void> updateModuloProgress(
    String userId,
    String moduloKey,
    ModuloProgreso progreso,
  ) async {
    try {
      await remoteDataSource.updateModuloProgress(userId, moduloKey, progreso);
    } catch (e) {
      throw Exception('Error en el repositorio al actualizar módulo: $e');
    }
  }

  @override
  Future<void> addEventToHistorial(String userId, int evento) async {
    try {
      await remoteDataSource.addEventToHistorial(userId, evento);
    } catch (e) {
      throw Exception('Error en el repositorio al agregar evento: $e');
    }
  }

  @override
  Future<void> updateEstadoGeneral(String userId, EstadoGeneral estado) async {
    try {
      await remoteDataSource.updateEstadoGeneral(userId, estado);
    } catch (e) {
      throw Exception('Error en el repositorio al actualizar estado: $e');
    }
  }

  @override
  Future<void> addInsigniaToUser(String userId, String insigniaId) async {
    try {
      await remoteDataSource.addInsigniaToUser(userId, insigniaId);
    } catch (e) {
      throw Exception('Error en el repositorio al agregar insignia: $e');
    }
  }

  @override
  Future<void> createGamificacionIfNotExists(String userId) async {
    try {
      await remoteDataSource.createGamificacionIfNotExists(userId);
    } catch (e) {
      throw Exception('Error en el repositorio al crear gamificación: $e');
    }
  }
}
