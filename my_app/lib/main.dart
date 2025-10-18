import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rive/rive.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:workmanager/workmanager.dart';
import 'core/di/injector.dart';
import 'app.dart';

// Callback para tareas en segundo plano
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Mantener la sesión de Firebase activa
      await Firebase.initializeApp();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Aquí puedes hacer tareas periódicas
        print('Tarea en segundo plano ejecutada para: ${user.email}');
      }
      
      return Future.value(true);
    } catch (e) {
      print('Error en tarea de fondo: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await setupDI();
  CachedNetworkImage.logLevel = CacheManagerLogLevel.none;
  
  // Inicializar timezone
  tzdata.initializeTimeZones();
  
  // Obtener el tema guardado previamente
  await RiveFile.initialize();

  // Mantener sesión activa
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      print('Usuario autenticado: ${user.email}');
      // La sesión se mantiene automáticamente
    } else {
      print('Usuario no autenticado');
    }
  });

  // Inicializar tareas en segundo plano (opcional)
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Programar tarea periódica cada 15 minutos
  // Descomenta si quieres tareas en segundo plano
  /*
  await Workmanager().registerPeriodicTask(
    'keep-session-alive',
    'checkSession',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      requiresDeviceIdle: false,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresConnectivity: true,
    ),
  );
  */
  
  await initializeDateFormatting('es_ES', null);
  runApp(MyApp());
}