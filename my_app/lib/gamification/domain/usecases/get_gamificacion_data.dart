import '../entities/gamificacion.dart';
import '../repositories/gamificacion_repository.dart';

class GetGamificacionData {
  final GamificacionRepository repository;

  GetGamificacionData({required this.repository});

  Future<Gamificacion> call(String userId) async {
    return await repository.getGamificacionData(userId);
  }
}