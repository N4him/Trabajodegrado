import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'has_seen_onboarding';
  
  // Verificar si el usuario ya vio el onboarding
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
      
      print('🔍 Verificando onboarding: ${hasSeenOnboarding ? "Ya visto" : "Primera vez"}');
      return hasSeenOnboarding;
    } catch (e) {
      print('❌ Error al verificar onboarding: $e');
      return false; // Si hay error, asumir que es primera vez
    }
  }
  
  // Marcar que el usuario ya vio el onboarding
  static Future<void> setOnboardingSeen() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      print('✅ Onboarding marcado como visto');
    } catch (e) {
      print('❌ Error al marcar onboarding como visto: $e');
    }
  }
  
  // Resetear el onboarding (útil para testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      print('🔄 Onboarding reseteado');
    } catch (e) {
      print('❌ Error al resetear onboarding: $e');
    }
  }
  
  // Limpiar todos los datos de onboarding
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🗑️ Todos los datos de onboarding eliminados');
    } catch (e) {
      print('❌ Error al limpiar datos de onboarding: $e');
    }
  }
}