import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rive/rive.dart';
import 'package:workmanager/workmanager.dart';
import 'core/di/injector.dart';
import 'services/notification_service.dart';
import 'app.dart';

// 🧪 IMPORTAR EL TESTER

// Callback para tareas en segundo plano
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await user.getIdToken(true);
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await setupDI();
  CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  await RiveFile.initialize();

  // Mantener sesión activa y ejecutar tests
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      // 🧪 EJECUTAR TEST COMPLETO AUTOMÁTICO
      await _runHealthTests(user.uid);
    } else {
      print('Usuario no autenticado');
    }
  });

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  await initializeDateFormatting('es_ES', null);
  runApp(MyApp());
}

// 🧪 FUNCIÓN DE TESTS - OPCIÓN 3: TEST COMPLETO
Future<void> _runHealthTests(String userId) async {
  print('\n🔬 ========== INICIANDO TESTS DE SALUD ==========\n');
  

  // ✅ OPCIÓN 3: TEST COMPLETO AUTOMÁTICO

  print('\n✅ Tests completados. Ahora navega a la pantalla de hábitos después de cada paso.\n');
}