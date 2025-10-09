import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await setupDI();

  // Obtener el tema guardado previamente

  FirebaseAuth.instance.authStateChanges().listen((user) {
    // Manejo de cambios de sesión (opcional)
  });

  runApp(MyApp());
}