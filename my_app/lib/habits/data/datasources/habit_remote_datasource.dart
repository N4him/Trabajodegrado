// data/datasources/habit_remote_datasource.dart

import '../models/habit_model.dart';
import '../models/completion_record_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:async'; 

abstract class HabitDataSource {
  Future<void> saveHabit(HabitModel habit);
  Future<List<HabitModel>> fetchHabitsByUserId(String userId);
  Future<void> saveCompletionRecord(CompletionRecordModel record);
  // Requiere ambos IDs para la ruta anidada
  Future<List<CompletionRecordModel>> fetchCompletionRecordsForHabit(String habitId, String userId);
  Future<void> deleteHabit(String habitId, String userId);
}

class HabitFirestoreDataSource implements HabitDataSource {
  final FirebaseFirestore firestore;

  HabitFirestoreDataSource({required this.firestore});

  // Referencia a la subcolección de HÁBITOS: users/{userId}/habits
  CollectionReference _getHabitsCollectionRef(String userId) {
    return firestore.collection('users').doc(userId).collection('habits');
  }

  // Referencia a la subcolección de REGISTROS: users/{userId}/habits/{habitId}/completionRecords
  CollectionReference _getRecordsCollectionRef(String userId, String habitId) {
    return _getHabitsCollectionRef(userId).doc(habitId).collection('completionRecords');
  }

  // --- 1. Guardar Hábito (users/{userId}/habits) ---
  @override
  Future<void> saveHabit(HabitModel habit) async {
    // 🔑 PUNTO DE VERIFICACIÓN 9.5: La llamada real a Firestore
    print('>>> 9.5. FIREBASE: Intentando guardar en la ruta users/${habit.userId}/habits.');

    final ref = _getHabitsCollectionRef(habit.userId);
    
    // Si habit.id está vacío, .doc(null) o .doc() deja que Firestore genere un ID.
    // Usamos .set() para crear o actualizar.
    await ref
      .doc(habit.id.isEmpty ? null : habit.id)
      .set(habit.toMap());
      
    print('>>> 9.6. FIREBASE: Guardado exitoso.');
  }
  
  // --- 2. Obtener Hábitos por Usuario (users/{userId}/habits) ---
  @override
  Future<List<HabitModel>> fetchHabitsByUserId(String userId) async {
    final snapshot = await _getHabitsCollectionRef(userId).get();

    return snapshot.docs.map((doc) {
      // ⭐️ CORRECCIÓN APLICADA AQUÍ: Comprobación de nulo y cast explícito.
      final data = doc.data() as Map<String, dynamic>?; 
      
      // Asegurar que 'data' no sea nulo antes de usar fromMap
      if (data == null) {
        // Podrías registrar un error o simplemente saltar este documento
        return null; 
      }
      return HabitModel.fromMap(data, doc.id);
    })
    .whereType<HabitModel>() // Filtra cualquier resultado nulo si doc.data() era null
    .toList();
  }

  // --- 3. Guardar Registro (users/{userId}/habits/{habitId}/records) ---
  @override
  Future<void> saveCompletionRecord(CompletionRecordModel record) async {
    // Usa userId y habitId para construir la ruta completa
    final ref = _getRecordsCollectionRef(record.userId, record.habitId);
    await ref
        .doc(record.id.isEmpty ? null : record.id) 
        .set(record.toMap());
  }

  // --- 4. Obtener Registros (users/{userId}/habits/{habitId}/records) ---
  @override
  Future<List<CompletionRecordModel>> fetchCompletionRecordsForHabit(String habitId, String userId) async {
    final snapshot = await _getRecordsCollectionRef(userId, habitId)
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      // ⭐️ CORRECCIÓN APLICADA AQUÍ: Comprobación de nulo y cast explícito.
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        return null;
      }
      return CompletionRecordModel.fromMap(data, doc.id);
    })
    .whereType<CompletionRecordModel>() // Filtra cualquier resultado nulo
    .toList();
  }

  // --- 5. Eliminar Hábito (users/{userId}/habits/{habitId}) ---
  @override
  Future<void> deleteHabit(String habitId, String userId) async {
    print('>>> FIREBASE: Eliminando hábito $habitId del usuario $userId');

    // Primero eliminar todos los registros de completitud
    final recordsSnapshot = await _getRecordsCollectionRef(userId, habitId).get();

    // Eliminar cada registro
    for (var doc in recordsSnapshot.docs) {
      await doc.reference.delete();
    }

    print('>>> FIREBASE: ${recordsSnapshot.docs.length} registros eliminados');

    // Luego eliminar el hábito
    await _getHabitsCollectionRef(userId).doc(habitId).delete();

    print('>>> FIREBASE: Hábito eliminado exitosamente');
  }
}