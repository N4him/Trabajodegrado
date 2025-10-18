// ========================================
// 1. lib/features/gamificacion/data/datasources/gamificacion_remote_data_source.dart
// ========================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamificacion_model.dart';
import '../../domain/entities/gamificacion.dart';
import '../../domain/entities/modulo_progreso.dart';

abstract class GamificacionRemoteDataSource {
  Future<GamificacionModel> getGamificacionData(String userId);
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

class GamificacionRemoteDataSourceImpl implements GamificacionRemoteDataSource {
  final FirebaseFirestore firestore;

  GamificacionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<GamificacionModel> getGamificacionData(String userId) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data');

      final doc = await docRef.get();

      if (!doc.exists) {
        // Crear datos iniciales si no existen
        await createGamificacionIfNotExists(userId);
        final newDoc = await docRef.get();
        return GamificacionModel.fromFirestore(newDoc);
      }

      return GamificacionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener datos de gamificación: $e');
    }
  }

  @override
  Future<void> createGamificacionIfNotExists(String userId) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data');

      final doc = await docRef.get();

      if (!doc.exists) {
        final initialData = GamificacionModel.empty();
        await docRef.set(initialData.toFirestore());
      }
    } catch (e) {
      throw Exception('Error al crear gamificación inicial: $e');
    }
  }

// En updateModuloProgress, reemplaza este método:

@override
Future<void> updateModuloProgress(
  String userId,
  String moduloKey,
  ModuloProgreso progreso,
) async {
  try {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('gamificacion')
        .doc('data');

    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('No existen datos de gamificación para el usuario');
    }

    final data = doc.data() as Map<String, dynamic>;
    final modulos = data['modulos'] as Map<String, dynamic>? ?? {};

    // Obtener el progreso actual del módulo (o crear uno nuevo con valores por defecto)
    final progresoActualMap = modulos[moduloKey] as Map<String, dynamic>? ?? {};
    final progresoActual = progresoActualMap.isEmpty
        ? ModuloProgreso()
        : ModuloProgreso.fromMap(progresoActualMap);

    // Sumar los nuevos valores con los actuales
    final progresoActualizado = progresoActual.copyWith(
      diasCumplidos: progresoActual.diasCumplidos + progreso.diasCumplidos,
      rachaActual: progresoActual.rachaActual + progreso.rachaActual,
      publicaciones: progresoActual.publicaciones + progreso.publicaciones,
      puntosObtenidos: progresoActual.puntosObtenidos + progreso.puntosObtenidos,
      lecturas: progresoActual.lecturas + progreso.lecturas,
      testsAprobados: progresoActual.testsAprobados + progreso.testsAprobados,
      sesionesCompletadas: progresoActual.sesionesCompletadas + progreso.sesionesCompletadas,
    );

    // Actualizar con los valores sumados
    await docRef.update({
      'modulos.$moduloKey': progresoActualizado.toMap(),
    });
  } catch (e) {
    throw Exception('Error al actualizar progreso del módulo: $e');
  }
}

  @override
  Future<void> addEventToHistorial(String userId, int evento) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data')
          .update({
        'historial_eventos': FieldValue.arrayUnion([evento]),
      });
    } catch (e) {
      throw Exception('Error al agregar evento al historial: $e');
    }
  }

  @override
  Future<void> updateEstadoGeneral(String userId, EstadoGeneral estado) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data')
          .update({
        'estado_general': {
          'planta_valor': estado.plantaValor,
          'salud': estado.salud,
          'etapa': estado.etapa,
          'ultima_actualizacion': Timestamp.fromDate(estado.ultimaActualizacion),
        },
      });
    } catch (e) {
      throw Exception('Error al actualizar estado general: $e');
    }
  }

  @override
  Future<void> addInsigniaToUser(String userId, String insigniaId) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('gamificacion')
          .doc('data');

      // CRÍTICO: Usar arrayUnion previene duplicados automáticamente
      await docRef.update({
        'insignias_usuario': FieldValue.arrayUnion([insigniaId]),
      });
      
      print('✅ Insignia agregada: $insigniaId'); // Debug log
    } catch (e) {
      throw Exception('Error al agregar insignia al usuario: $e');
    }
  }
}