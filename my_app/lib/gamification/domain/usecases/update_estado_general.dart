import '../entities/gamificacion.dart';
import '../repositories/gamificacion_repository.dart';

class UpdateEstadoGeneral {
  final GamificacionRepository repository;

  UpdateEstadoGeneral({required this.repository});

  Future<void> call({
    required String userId,
    required EstadoGeneral estadoGeneral,
  }) async {
    print('🎯 [USE CASE] Iniciando updateEstadoGeneral');
    print('🎯 [USE CASE] userId: $userId');
    print('🎯 [USE CASE] plantaValor: ${estadoGeneral.plantaValor}');
    print('🎯 [USE CASE] salud: ${estadoGeneral.salud}');
    print('🎯 [USE CASE] etapa: ${estadoGeneral.etapa}');
    
    // Validaciones
    if (estadoGeneral.plantaValor < 0) {
      print('❌ [USE CASE] Error: plantaValor negativo');
      throw Exception('El valor de la planta no puede ser negativo');
    }
    
    if (estadoGeneral.salud < 0 || estadoGeneral.salud > 100) {
      print('❌ [USE CASE] Error: salud fuera de rango');
      throw Exception('La salud debe estar entre 0 y 100');
    }

    final etapasValidas = ['semilla', 'germinacion', 'crecimiento', 'floracion', 'fruto'];
    if (!etapasValidas.contains(estadoGeneral.etapa)) {
      print('❌ [USE CASE] Error: etapa no válida');
      throw Exception('Etapa no válida. Debe ser una de: ${etapasValidas.join(", ")}');
    }

    print('🎯 [USE CASE] Validaciones OK, llamando al repositorio...');
    
    // Llamar al repositorio
    await repository.updateEstadoGeneral(userId, estadoGeneral);
    
    print('✅ [USE CASE] Repositorio completado');
  }
}