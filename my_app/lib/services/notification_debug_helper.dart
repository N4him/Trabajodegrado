import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Helper para diagnosticar problemas con notificaciones
class NotificationDebugHelper {
  final NotificationService notificationService;

  NotificationDebugHelper(this.notificationService);

  /// Verifica el estado de las notificaciones y permisos
  Future<Map<String, dynamic>> checkStatus() async {
    final Map<String, dynamic> status = {};

    try {
      // 1. Verificar notificaciones pendientes
      final pendingNotifications = await notificationService.getPendingNotifications();
      status['pendingCount'] = pendingNotifications.length;
      status['pendingNotifications'] = pendingNotifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'payload': n.payload,
      }).toList();

      debugPrint('📊 DIAGNÓSTICO DE NOTIFICACIONES:');
      debugPrint('   Notificaciones pendientes: ${pendingNotifications.length}');

      for (var notification in pendingNotifications) {
        debugPrint('   - ID: ${notification.id}');
        debugPrint('     Título: ${notification.title}');
        debugPrint('     Mensaje: ${notification.body}');
        debugPrint('     Payload: ${notification.payload}');
      }

      if (pendingNotifications.isEmpty) {
        debugPrint('   ⚠️ NO HAY NOTIFICACIONES PROGRAMADAS');
      }

    } catch (e) {
      status['error'] = e.toString();
      debugPrint('❌ Error al verificar notificaciones: $e');
    }

    return status;
  }

  /// Programa una notificación de prueba en 10 segundos
  Future<void> scheduleTestNotification() async {
    try {
      debugPrint('🧪 Programando notificación de prueba en 10 segundos...');

      // Crear un hábito de prueba con hora dentro de 10 segundos
      final now = DateTime.now();
      final testTime = now.add(const Duration(seconds: 10));
      final timeString = '${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}';

      debugPrint('   Hora actual: ${now.hour}:${now.minute}:${now.second}');
      debugPrint('   Notificación programada para: $timeString');

      // Nota: Necesitarías crear un HabitEntity de prueba aquí
      // Por ahora solo mostramos el mensaje

      debugPrint('✅ Notificación de prueba programada');

    } catch (e) {
      debugPrint('❌ Error al programar notificación de prueba: $e');
    }
  }
}
