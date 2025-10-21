import '../entities/gamificacion.dart';
import '../entities/insignia.dart';
import '../repositories/gamificacion_repository.dart';
import '../repositories/insignia_repository.dart';

class CheckAndUnlockInsignias {
  final InsigniaRepository insigniaRepository;
  final GamificacionRepository gamificacionRepository;

  CheckAndUnlockInsignias({
    required this.insigniaRepository,
    required this.gamificacionRepository,
  });

  Future<List<Insignia>> call({
    required String userId,
    required Gamificacion gamificacion,
  }) async {
    
    // Obtener todas las insignias disponibles
    final todasInsignias = await insigniaRepository.getAllInsignias();
    
    // Filtrar las que ya tiene el usuario
    final insigniasDesbloqueadas = <Insignia>[];
    
    for (final insignia in todasInsignias) {
      // CRÍTICO: Si ya la tiene, no la procesamos
      if (gamificacion.insigniasUsuario.contains(insignia.id)) {
        continue;
      }
      
      // Verificar si cumple el requisito
      final cumple = _cumpleRequisito(insignia.requisito, gamificacion);
      
      if (cumple) {
        
        // Agregar insignia al usuario
        await gamificacionRepository.addInsigniaToUser(userId, insignia.id);
        insigniasDesbloqueadas.add(insignia);
      }
    }
    
    return insigniasDesbloqueadas;
  }

  bool _cumpleRequisito(Requisito requisito, Gamificacion gamificacion) {
    switch (requisito.tipo) {
      case 'habitos':
        final modulo = gamificacion.modulos['habitos'];
        final cumple = (modulo?.diasCumplidos ?? 0) >= requisito.valor;
        return cumple;
      
      case 'foro':
        final modulo = gamificacion.modulos['foro'];
        final cumple = (modulo?.publicaciones ?? 0) >= requisito.valor;
        return cumple;
      
      case 'biblioteca':
        final modulo = gamificacion.modulos['biblioteca'];
        final cumple = (modulo?.lecturas ?? 0) >= requisito.valor;
        return cumple;
      
      case 'equilibrio':
        final modulo = gamificacion.modulos['equilibrio'];
        final cumple = (modulo?.sesionesCompletadas ?? 0) >= requisito.valor;
        return cumple;
      
      case 'racha':
        final modulo = gamificacion.modulos['habitos'];
        final cumple = (modulo?.rachaActual ?? 0) >= requisito.valor;
        return cumple;
      
      default:
        return false;
    }
  }
}