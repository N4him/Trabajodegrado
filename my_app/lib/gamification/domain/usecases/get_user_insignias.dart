import '../entities/insignia.dart';
import '../repositories/insignia_repository.dart';

class GetUserInsignias {
  final InsigniaRepository repository;

  GetUserInsignias({required this.repository});

  Future<List<Insignia>> call(String userId) async {
    // Cambiar a usar el método que combina todas las insignias con el estado del usuario
    return await repository.getAllInsigniasWithUserStatus(userId);
  }
}