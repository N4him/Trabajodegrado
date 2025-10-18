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
    print('🔍 Verificando insignias para usuario: $userId');
    print('📋 Insignias actuales del usuario: ${gamificacion.insigniasUsuario}');
    
    // Obtener todas las insignias disponibles
    final todasInsignias = await insigniaRepository.getAllInsignias();
    print('🎯 Total de insignias disponibles: ${todasInsignias.length}');
    
    // Filtrar las que ya tiene el usuario
    final insigniasDesbloqueadas = <Insignia>[];
    
    for (final insignia in todasInsignias) {
      // CRÍTICO: Si ya la tiene, no la procesamos
      if (gamificacion.insigniasUsuario.contains(insignia.id)) {
        print('⏭️ Insignia "${insignia.nombre}" ya desbloqueada, saltando...');
        continue;
      }
      
      // Verificar si cumple el requisito
      final cumple = _cumpleRequisito(insignia.requisito, gamificacion);
      print('🎲 Insignia "${insignia.nombre}": Cumple requisito = $cumple');
      
      if (cumple) {
        print('🎉 Desbloqueando insignia: ${insignia.nombre} (${insignia.id})');
        
        // Agregar insignia al usuario
        await gamificacionRepository.addInsigniaToUser(userId, insignia.id);
        insigniasDesbloqueadas.add(insignia);
      }
    }
    
    print('✨ Total de insignias desbloqueadas en esta verificación: ${insigniasDesbloqueadas.length}');
    return insigniasDesbloqueadas;
  }

  bool _cumpleRequisito(Requisito requisito, Gamificacion gamificacion) {
    switch (requisito.tipo) {
      case 'habitos':
        final modulo = gamificacion.modulos['habitos'];
        final cumple = (modulo?.diasCumplidos ?? 0) >= requisito.valor;
        print('   📊 Hábitos: ${modulo?.diasCumplidos ?? 0} >= ${requisito.valor} = $cumple');
        return cumple;
      
      case 'foro':
        final modulo = gamificacion.modulos['foro'];
        final cumple = (modulo?.publicaciones ?? 0) >= requisito.valor;
        print('   📊 Foro: ${modulo?.publicaciones ?? 0} >= ${requisito.valor} = $cumple');
        return cumple;
      
      case 'biblioteca':
        final modulo = gamificacion.modulos['biblioteca'];
        final cumple = (modulo?.lecturas ?? 0) >= requisito.valor;
        print('   📊 Biblioteca: ${modulo?.lecturas ?? 0} >= ${requisito.valor} = $cumple');
        return cumple;
      
      case 'equilibrio':
        final modulo = gamificacion.modulos['equilibrio'];
        final cumple = (modulo?.sesionesCompletadas ?? 0) >= requisito.valor;
        print('   📊 Equilibrio: ${modulo?.sesionesCompletadas ?? 0} >= ${requisito.valor} = $cumple');
        return cumple;
      
      case 'racha':
        final modulo = gamificacion.modulos['habitos'];
        final cumple = (modulo?.rachaActual ?? 0) >= requisito.valor;
        print('   📊 Racha: ${modulo?.rachaActual ?? 0} >= ${requisito.valor} = $cumple');
        return cumple;
      
      default:
        return false;
    }
  }
}