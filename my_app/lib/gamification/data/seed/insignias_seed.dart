// ========================================
// lib/features/gamificacion/data/seed/insignias_seed.dart
// ========================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Este archivo contiene las insignias iniciales que deben crearse en Firestore
/// Ejecuta esta función una vez para poblar la colección de insignias

class InsigniasSeed {
  static Future<void> seedInsignias() async {
    final firestore = FirebaseFirestore.instance;
    final insigniasCollection = firestore.collection('insignias');

    final insignias = [
      // ==================== Insignias de Hábitos ====================
      {
        'nombre': 'Primer Paso',
        'descripcion': 'Completa tu primer día de hábitos',
        'icono': 'star',
        'requisito': {
          'tipo': 'habitos',
          'valor': 1,
        },
        'puntos_otorgados': 10,
      },
      {
        'nombre': 'Constancia',
        'descripcion': 'Mantén una racha de 7 días',
        'icono': 'fire',
        'requisito': {
          'tipo': 'racha',
          'valor': 7,
        },
        'puntos_otorgados': 50,
      },
      {
        'nombre': 'Maestro de Hábitos',
        'descripcion': 'Completa 30 días de hábitos',
        'icono': 'trophy',
        'requisito': {
          'tipo': 'habitos',
          'valor': 30,
        },
        'puntos_otorgados': 100,
      },
      {
        'nombre': 'Imparable',
        'descripcion': 'Mantén una racha de 30 días consecutivos',
        'icono': 'fire',
        'requisito': {
          'tipo': 'racha',
          'valor': 30,
        },
        'puntos_otorgados': 200,
      },
      {
        'nombre': 'Leyenda',
        'descripcion': 'Completa 100 días de hábitos',
        'icono': 'trophy',
        'requisito': {
          'tipo': 'habitos',
          'valor': 100,
        },
        'puntos_otorgados': 500,
      },

      // ==================== Insignias de Foro ====================
      {
        'nombre': 'Primera Voz',
        'descripcion': 'Realiza tu primera publicación en el foro',
        'icono': 'chat',
        'requisito': {
          'tipo': 'foro',
          'valor': 1,
        },
        'puntos_otorgados': 10,
      },
      {
        'nombre': 'Conversador',
        'descripcion': 'Realiza 10 publicaciones en el foro',
        'icono': 'chat',
        'requisito': {
          'tipo': 'foro',
          'valor': 10,
        },
        'puntos_otorgados': 50,
      },
      {
        'nombre': 'Líder de Comunidad',
        'descripcion': 'Realiza 50 publicaciones en el foro',
        'icono': 'chat',
        'requisito': {
          'tipo': 'foro',
          'valor': 50,
        },
        'puntos_otorgados': 150,
      },
      {
        'nombre': 'Influencer',
        'descripcion': 'Realiza 100 publicaciones en el foro',
        'icono': 'chat',
        'requisito': {
          'tipo': 'foro',
          'valor': 100,
        },
        'puntos_otorgados': 300,
      },

      // ==================== Insignias de Biblioteca ====================
      {
        'nombre': 'Lector Principiante',
        'descripcion': 'Lee tu primer libro',
        'icono': 'book',
        'requisito': {
          'tipo': 'biblioteca',
          'valor': 1,
        },
        'puntos_otorgados': 10,
      },
      {
        'nombre': 'Bibliotecario',
        'descripcion': 'Lee 5 libros',
        'icono': 'book',
        'requisito': {
          'tipo': 'biblioteca',
          'valor': 5,
        },
        'puntos_otorgados': 50,
      },
      {
        'nombre': 'Sabio',
        'descripcion': 'Lee 20 libros',
        'icono': 'book',
        'requisito': {
          'tipo': 'biblioteca',
          'valor': 20,
        },
        'puntos_otorgados': 150,
      },
      {
        'nombre': 'Erudito',
        'descripcion': 'Lee 50 libros',
        'icono': 'book',
        'requisito': {
          'tipo': 'biblioteca',
          'valor': 50,
        },
        'puntos_otorgados': 400,
      },

      // ==================== Insignias de Equilibrio ====================
      {
        'nombre': 'Paz Interior',
        'descripcion': 'Completa tu primera sesión de equilibrio',
        'icono': 'meditation',
        'requisito': {
          'tipo': 'equilibrio',
          'valor': 1,
        },
        'puntos_otorgados': 10,
      },
      {
        'nombre': 'Zen',
        'descripcion': 'Completa 10 sesiones de equilibrio',
        'icono': 'meditation',
        'requisito': {
          'tipo': 'equilibrio',
          'valor': 10,
        },
        'puntos_otorgados': 50,
      },
      {
        'nombre': 'Maestro del Equilibrio',
        'descripcion': 'Completa 50 sesiones de equilibrio',
        'icono': 'meditation',
        'requisito': {
          'tipo': 'equilibrio',
          'valor': 50,
        },
        'puntos_otorgados': 200,
      },
      {
        'nombre': 'Iluminado',
        'descripcion': 'Completa 100 sesiones de equilibrio',
        'icono': 'meditation',
        'requisito': {
          'tipo': 'equilibrio',
          'valor': 100,
        },
        'puntos_otorgados': 500,
      },
    ];

    for (final insignia in insignias) {
      await insigniasCollection.add(insignia);
    }

  }
}

/// ==================== INSTRUCCIONES DE USO ====================
/// 
/// Opción 1: Crear un botón temporal en tu UI para ejecutar la función:
/// 
/// ElevatedButton(
///   onPressed: () async {
///     try {
///       await InsigniasSeed.seedInsignias();
///       ScaffoldMessenger.of(context).showSnackBar(
///         const SnackBar(content: Text('✅ Insignias creadas exitosamente')),
///       );
///     } catch (e) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('❌ Error: $e')),
///       );
///     }
///   },
///   child: const Text('Crear Insignias Iniciales'),
/// )
///
/// Opción 2: Ejecutar desde main.dart al iniciar la app (solo una vez):
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   
///   // Descomentar solo la primera vez para crear las insignias
///   // await InsigniasSeed.seedInsignias();
///   
///   runApp(const MyApp());
/// }