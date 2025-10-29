import '../repositories/gamificacion_repository.dart';

class AddEventToHistorial {
  final GamificacionRepository repository;

  AddEventToHistorial({required this.repository});

  Future<void> call({
    required String userId,
    required DateTime fecha,
  }) async {
    // Convertir fecha a formato yyyymmdd
    final evento = int.parse(
      '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}',
    );
    
    await repository.addEventToHistorial(userId, evento);
  }
}