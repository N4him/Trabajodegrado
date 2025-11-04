/// Script de migración de datos de WellbeingPoints a Gamificación
///
/// Este script migra los puntos existentes del sistema antiguo de wellbeing_points
/// al nuevo sistema de gamificación unificado.
///
/// INSTRUCCIONES DE USO:
/// 1. Asegúrate de que el proyecto esté compilado correctamente
/// 2. Ejecuta este script con: dart run lib/scripts/migrate_wellbeing_to_gamification.dart
/// 3. El script:
///    - Lee todos los documentos de la colección wellbeing_points
///    - Migra los puntos al módulo 'equilibrio' en gamificacion
///    - NO elimina los datos antiguos (por seguridad)
///
/// IMPORTANTE: Este script debe ejecutarse UNA SOLA VEZ después del deployment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  print('🚀 Iniciando migración de WellbeingPoints a Gamificación...\n');

  // Inicializar Firebase
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  try {
    // 1. Obtener todos los documentos de wellbeing_points
    print('📊 Buscando datos de wellbeing_points...');
    final wellbeingSnapshot = await firestore
        .collection('wellbeing_points')
        .get();

    if (wellbeingSnapshot.docs.isEmpty) {
      print('⚠️  No se encontraron datos de wellbeing_points para migrar.');
      return;
    }

    print('✅ Encontrados ${wellbeingSnapshot.docs.length} usuarios con datos de wellbeing.\n');

    int migratedCount = 0;
    int errorCount = 0;

    // 2. Migrar cada usuario
    for (final doc in wellbeingSnapshot.docs) {
      final userId = doc.id;
      final data = doc.data();

      try {
        // Extraer datos del sistema antiguo
        final activityPoints = data['activity_points'] as Map<String, dynamic>? ?? {};
        final totalPoints = data['total_points'] as int? ?? 0;
        final lastUpdated = data['last_updated'] as Timestamp?;

        print('🔄 Migrando usuario: $userId');
        print('   Puntos totales antiguos: $totalPoints');

        // Calcular sesiones completadas (estimación basada en puntos)
        // Asumiendo 1 punto = 1 sesión por actividad por día
        final breathingPoints = activityPoints['breathing_game'] as int? ?? 0;
        final bodyScanPoints = activityPoints['body_scan'] as int? ?? 0;
        final questMapPoints = activityPoints['quest_map'] as int? ?? 0;

        final totalSessions = breathingPoints + bodyScanPoints + questMapPoints;

        // Referencia al documento de gamificación del usuario
        final gamificacionRef = firestore
            .collection('users')
            .doc(userId)
            .collection('gamificacion')
            .doc('data');

        // Verificar si ya existe el documento de gamificación
        final gamificacionDoc = await gamificacionRef.get();

        if (gamificacionDoc.exists) {
          // Si ya existe, actualizar el módulo equilibrio sumando los puntos
          print('   ℹ️  Ya existe gamificación para este usuario, actualizando...');

          final existingData = gamificacionDoc.data() as Map<String, dynamic>;
          final modulos = existingData['modulos'] as Map<String, dynamic>? ?? {};
          final equilibrioData = modulos['equilibrio'] as Map<String, dynamic>? ?? {};

          final currentPoints = equilibrioData['puntos_obtenidos'] as int? ?? 0;
          final currentSessions = equilibrioData['sesiones_completadas'] as int? ?? 0;

          await gamificacionRef.update({
            'modulos.equilibrio.puntos_obtenidos': currentPoints + totalPoints,
            'modulos.equilibrio.sesiones_completadas': currentSessions + totalSessions,
          });

          print('   ✅ Puntos migrados: $totalPoints (Total ahora: ${currentPoints + totalPoints})');
        } else {
          // Si no existe, crear estructura inicial con los puntos migrados
          print('   📝 Creando nueva estructura de gamificación...');

          await gamificacionRef.set({
            'modulos': {
              'equilibrio': {
                'dias_cumplidos': 0,
                'racha_actual': 0,
                'publicaciones': 0,
                'puntos_obtenidos': totalPoints,
                'lecturas': 0,
                'tests_aprobados': 0,
                'sesiones_completadas': totalSessions,
              },
              'habitos': {
                'dias_cumplidos': 0,
                'racha_actual': 0,
                'publicaciones': 0,
                'puntos_obtenidos': 0,
                'lecturas': 0,
                'tests_aprobados': 0,
                'sesiones_completadas': 0,
              },
              'foro': {
                'dias_cumplidos': 0,
                'racha_actual': 0,
                'publicaciones': 0,
                'puntos_obtenidos': 0,
                'lecturas': 0,
                'tests_aprobados': 0,
                'sesiones_completadas': 0,
              },
              'biblioteca': {
                'dias_cumplidos': 0,
                'racha_actual': 0,
                'publicaciones': 0,
                'puntos_obtenidos': 0,
                'lecturas': 0,
                'tests_aprobados': 0,
                'sesiones_completadas': 0,
              },
            },
            'estado_general': {
              'planta_valor': 0,
              'salud': 100,
              'etapa': 'semilla',
              'ultima_actualizacion': FieldValue.serverTimestamp(),
            },
            'historial_eventos': [],
            'insignias_usuario': [],
          });

          print('   ✅ Gamificación creada con $totalPoints puntos en equilibrio');
        }

        migratedCount++;
        print('');

      } catch (e) {
        print('   ❌ Error al migrar usuario $userId: $e\n');
        errorCount++;
      }
    }

    // 3. Resumen final
    print('═' * 60);
    print('📊 RESUMEN DE MIGRACIÓN');
    print('═' * 60);
    print('✅ Usuarios migrados exitosamente: $migratedCount');
    print('❌ Errores: $errorCount');
    print('📝 Total procesados: ${wellbeingSnapshot.docs.length}');
    print('');
    print('⚠️  IMPORTANTE: Los datos antiguos de wellbeing_points NO han sido eliminados.');
    print('   Puedes eliminarlos manualmente desde la consola de Firebase si lo deseas.');
    print('   Ubicación: Cloud Firestore > wellbeing_points (colección)');
    print('');
    print('🎉 Migración completada!\n');

  } catch (e) {
    print('❌ Error crítico durante la migración: $e');
    rethrow;
  }
}
