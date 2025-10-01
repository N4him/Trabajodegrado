import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await setupDI();

  // Obtener el tema guardado previamente
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  FirebaseAuth.instance.authStateChanges().listen((user) {
    // Manejo de cambios de sesión (opcional)
  });

  runApp(MyApp(savedThemeMode: savedThemeMode));
}