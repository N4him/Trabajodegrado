// ignore_for_file: empty_catches

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'has_seen_onboarding';
  
  // Verificar si el usuario ya vio el onboarding
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
      
      return hasSeenOnboarding;
    } catch (e) {
      return false; // Si hay error, asumir que es primera vez
    }
  }
  
  // Marcar que el usuario ya vio el onboarding
  static Future<void> setOnboardingSeen() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
    }
  }
  
  // Resetear el onboarding (útil para testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
    } catch (e) {
    }
  }
  
  // Limpiar todos los datos de onboarding
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
    }
  }
}