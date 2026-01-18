import 'package:flutter/material.dart';
import '../core/di/injector.dart';
import 'notification_service.dart';
import '../habits/domain/entities/habit_entity.dart';

/// Pantalla de prueba para notificaciones
/// TEMPORAL - Solo para debugging
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final notificationService = getIt<NotificationService>();
  String _status = 'Esperando...';
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final pending = await notificationService.getPendingNotifications();
    setState(() {
      _pendingCount = pending.length;
      _status = 'Notificaciones pendientes: ${pending.length}';
    });

    print('📊 Status de notificaciones:');
    for (var n in pending) {
      print('  - ${n.title} (ID: ${n.id})');
    }
  }

  Future<void> _scheduleTestNotification() async {
    // Crear notificación de prueba en 10 segundos
    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));

    final hour = testTime.hour;
    final minute = testTime.minute;

    // Formatear en formato AM/PM
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

    print('⏰ Programando notificación de prueba...');
    print('   Hora actual: ${now.hour}:${now.minute}:${now.second}');
    print('   Notificación para: $hour:$minute ($timeString)');

    final testHabit = HabitEntity(
      id: 'test-notification-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'test-user',
      name: 'Prueba de Notificación',
      frequencyDays: 7,
      startDate: DateTime.now(),
      reminderTime: timeString,
    );

    await notificationService.scheduleHabitReminder(testHabit);

    setState(() {
      _status = 'Notificación de prueba programada para $timeString\n(en 10 segundos)';
    });

    await _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Notificaciones'),
        backgroundColor: const Color(0xFFCDB290),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    Text(
                      'Notificaciones programadas: $_pendingCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _pendingCount > 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _scheduleTestNotification,
              icon: const Icon(Icons.alarm_add),
              label: const Text('Programar Notificación de Prueba (10 seg)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDB290),
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar Estado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await notificationService.cancelAllNotifications();
                setState(() {
                  _status = 'Todas las notificaciones canceladas';
                  _pendingCount = 0;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Cancelar Todas las Notificaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Presiona el botón de prueba\n'
                      '2. Espera 10 segundos\n'
                      '3. Deberías recibir una notificación\n'
                      '4. Si no llega, revisa los permisos',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
