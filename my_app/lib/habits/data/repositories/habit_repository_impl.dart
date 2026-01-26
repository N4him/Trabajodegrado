import '../../domain/repositories/habit_repository.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/completion_record_entity.dart';
import '../datasources/habit_remote_datasource.dart'; 
import '../models/habit_model.dart';
import '../models/completion_record_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitDataSource dataSource; 

  HabitRepositoryImpl({required this.dataSource}) { 
    // 🔑 PUNTO DE VERIFICACIÓN 7.5: Se instancia el repositorio
    print('>>> 7.5. Repositorio INSTANCIADO. DataSource recibido.'); 
  }

  // IMPLEMENTACIÓN DE createHabit
  @override
  Future<void> createHabit(HabitEntity habit) async {
    try {
      // 1. Mapear la Entidad del Dominio al Modelo de Datos
      // Asegúrate de que este método existe en tu HabitModel.
      final habitModel = HabitModel.fromEntity(habit); 
      
      // 🔑 PUNTO DE VERIFICACIÓN 8: ¿Llegamos a la capa de Datos?
      print('>>> 8. Repositorio INICIADO: Llamando a saveHabit en DataSource.'); 

      // 2. Llamar al DataSource para guardar
      await dataSource.saveHabit(habitModel);
      
      print('>>> 9. Repositorio FINALIZADO: Firestore ha respondido.');
      
    } catch (e) {
      print('>>> ❌ FALLO DE FIREBASE EN REPOSITORY: Error al guardar: $e');
      throw e; // Relanzar para que el BLoC lo capture
    }
  }

  // ✅ 2. IMPLEMENTACIÓN FALTANTE: getHabitsByUserId
  @override
  Future<List<HabitEntity>> getHabitsByUserId(String userId) async {
    // 1. Obtener los Modelos del DataSource
    final habitModels = await dataSource.fetchHabitsByUserId(userId);
    // 2. Mapear cada Modelo a una Entidad y devolver la lista
    return habitModels.map((model) => model.toEntity()).toList();
  }

  // ✅ 3. IMPLEMENTACIÓN COMPLETA: updateHabit (asume que saveHabit lo maneja)
  @override
  Future<void> updateHabit(HabitEntity habit) async {
    final habitModel = HabitModel.fromEntity(habit);
    await dataSource.saveHabit(habitModel);
  }

  // ✅ 4. IMPLEMENTACIÓN COMPLETA: registerCompletion
  @override
  Future<void> registerCompletion(CompletionRecordEntity record) async {
    final recordModel = CompletionRecordModel.fromEntity(record); 
    await dataSource.saveCompletionRecord(recordModel);
  }
  
  // ✅ 5. IMPLEMENTACIÓN COMPLETA: getCompletionRecordsForHabit
  @override
  Future<List<CompletionRecordEntity>> getCompletionRecordsForHabit(String habitId, String userId) async {
    final recordModels = await dataSource.fetchCompletionRecordsForHabit(habitId, userId);
    return recordModels.map((model) => model.toEntity()).toList();
  }

  // ✅ 6. IMPLEMENTACIÓN COMPLETA: deleteHabit
  @override
  Future<void> deleteHabit(String habitId, String userId) async {
    try {
      print('>>> Repositorio: Eliminando hábito $habitId');
      await dataSource.deleteHabit(habitId, userId);
      print('>>> Repositorio: Hábito eliminado exitosamente');
    } catch (e) {
      print('>>> ❌ FALLO EN REPOSITORY: Error al eliminar: $e');
      throw e;
    }
  }
}