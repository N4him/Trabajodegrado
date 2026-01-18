import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../habits/domain/entities/habit_entity.dart';

/// Servicio para gestionar notificaciones locales de hábitos
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa el sistema de notificaciones
  Future<void> initialize() async {
    debugPrint('🚀 INICIANDO NotificationService...');

    if (_isInitialized) {
      debugPrint('⚠️ NotificationService ya está inicializado');
      return;
    }

    try {
      // Inicializar zonas horarias
      debugPrint('   Paso 1: Inicializando base de datos de zonas horarias...');
      tz.initializeTimeZones();
      debugPrint('   ✅ Zonas horarias inicializadas');

      // Detectar zona horaria del dispositivo usando el offset de DateTime
      debugPrint('   Paso 2: Detectando zona horaria del dispositivo...');
      final String localTimeZone = _detectLocalTimezone();
      debugPrint('   🌍 Zona horaria detectada: $localTimeZone');

      // Configurar la zona horaria
      debugPrint('   Paso 3: Configurando zona horaria como local...');
      final location = tz.getLocation(localTimeZone);
      tz.setLocalLocation(location);
      debugPrint('   ✅ setLocalLocation completado');

      // Verificar que se configuró correctamente
      debugPrint('   Paso 4: Verificando configuración...');
      final deviceNow = DateTime.now();
      final tzNow = tz.TZDateTime.from(deviceNow, tz.local);
      debugPrint('   ✅ Zona horaria configurada: ${tz.local.name}');
      debugPrint('   📍 Hora del dispositivo (DateTime.now()): ${deviceNow.hour}:${deviceNow.minute}:${deviceNow.second}');
      debugPrint('   📍 Offset del dispositivo: ${deviceNow.timeZoneOffset}');
      debugPrint('   📍 Hora TZ convertida: ${tzNow.hour}:${tzNow.minute}:${tzNow.second}');

      // Configuración para Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuración general
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar plugin
      debugPrint('   Paso 5: Inicializando plugin de notificaciones...');
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      debugPrint('   ✅ Plugin inicializado');

      _isInitialized = true;
      debugPrint('');
      debugPrint('🎉 NotificationService COMPLETAMENTE INICIALIZADO');
      debugPrint('   Zona horaria activa: ${tz.local.name}');
      debugPrint('');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR CRÍTICO al inicializar NotificationService: $e');
      debugPrint('   Stack trace: $stackTrace');
    }
  }

  /// Maneja el evento cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación tocada: ${response.payload}');
    // TODO: Navegar a la pantalla del hábito específico
    // Puedes usar un NavigatorKey global o un service locator
  }

  /// Solicita permisos de notificaciones (especialmente para Android 13+)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Programa un recordatorio diario para un hábito
  Future<void> scheduleHabitReminder(HabitEntity habit) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService no inicializado');
      return;
    }

    // Si el hábito no tiene reminderTime, no hacer nada
    if (habit.reminderTime == null || habit.reminderTime!.isEmpty) {
      return;
    }

    try {
      debugPrint('🔔 Intentando programar notificación para: ${habit.name}');
      debugPrint('   Hora recibida: ${habit.reminderTime}');

      // FORZAR reconfiguración de zona horaria (por si fue sobrescrita)
      final localTimeZone = _detectLocalTimezone();
      final location = tz.getLocation(localTimeZone);
      tz.setLocalLocation(location);
      debugPrint('   🔄 Zona horaria reconfigurada a: ${tz.local.name}');

      final deviceNow = DateTime.now();
      debugPrint('   📍 Hora actual del dispositivo: ${deviceNow.hour}:${deviceNow.minute}:${deviceNow.second}');

      // Parsear la hora (formato: "9:00 AM" o "21:30")
      final timeOfDay = _parseTimeString(habit.reminderTime!);
      if (timeOfDay == null) {
        debugPrint('⚠️ No se pudo parsear la hora: ${habit.reminderTime}');
        return;
      }

      debugPrint('   Hora parseada: ${timeOfDay['hour']}:${timeOfDay['minute']}');

      // Obtener la próxima fecha/hora para la notificación
      final scheduledDate = _nextInstanceOfTime(
        timeOfDay['hour']!,
        timeOfDay['minute']!,
      );

      debugPrint('   Fecha programada: $scheduledDate');
      debugPrint('   Fecha actual (device): $deviceNow');

      // Configurar los detalles de la notificación
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'habit_reminders', // Channel ID
        'Recordatorios de Hábitos', // Channel name
        channelDescription: 'Notificaciones para recordar tus hábitos diarios',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Programar la notificación recurrente diaria
      await _notifications.zonedSchedule(
        _getNotificationId(habit.id), // ID único basado en el ID del hábito
        'Recordatorio: ${habit.name}',
        'Es hora de cumplir tu hábito 🌟',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
        payload: habit.id, // Para identificar el hábito cuando se toque
      );

      debugPrint('✅ Notificación programada para "${habit.name}" a las ${habit.reminderTime}');
      debugPrint('   ID de notificación: ${_getNotificationId(habit.id)}');

      // Verificar que se programó correctamente
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('   Total de notificaciones pendientes: ${pending.length}');
    } catch (e) {
      debugPrint('❌ Error al programar notificación para ${habit.name}: $e');
      debugPrint('   Stack trace: $e');
    }
  }

  /// Cancela la notificación de un hábito específico
  Future<void> cancelNotification(String habitId) async {
    if (!_isInitialized) return;

    try {
      final notificationId = _getNotificationId(habitId);
      await _notifications.cancel(notificationId);
      debugPrint('✅ Notificación cancelada para hábito: $habitId');
    } catch (e) {
      debugPrint('❌ Error al cancelar notificación: $e');
    }
  }

  /// Sincroniza todas las notificaciones con la lista de hábitos actual
  Future<void> syncAllNotifications(List<HabitEntity> habits) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService no inicializado para sincronización');
      return;
    }

    try {
      // FORZAR reconfiguración de zona horaria
      final localTimeZone = _detectLocalTimezone();
      final location = tz.getLocation(localTimeZone);
      tz.setLocalLocation(location);
      debugPrint('🔄 Zona horaria reconfigurada a: ${tz.local.name}');

      // Cancelar todas las notificaciones pendientes primero
      await _notifications.cancelAll();
      debugPrint('🔄 Sincronizando notificaciones para ${habits.length} hábitos');

      // Programar notificaciones solo para hábitos con reminderTime
      int programadas = 0;
      for (final habit in habits) {
        if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
          await scheduleHabitReminder(habit);
          programadas++;
        }
      }

      debugPrint('✅ Sincronización completa: $programadas notificaciones programadas');
    } catch (e) {
      debugPrint('❌ Error durante la sincronización: $e');
    }
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _notifications.cancelAll();
    debugPrint('✅ Todas las notificaciones canceladas');
  }

  /// Parsea una cadena de hora en formato "9:00 AM" o "21:30"
  Map<String, int>? _parseTimeString(String timeStr) {
    try {
      // Intentar formato con AM/PM
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final isPM = parts[1].toUpperCase() == 'PM';

        // Convertir a formato 24 horas
        if (isPM && hour != 12) {
          hour += 12;
        } else if (!isPM && hour == 12) {
          hour = 0;
        }

        return {'hour': hour, 'minute': minute};
      } else {
        // Formato 24 horas directo (ej: "21:30")
        final parts = timeStr.split(':');
        return {
          'hour': int.parse(parts[0]),
          'minute': int.parse(parts[1]),
        };
      }
    } catch (e) {
      debugPrint('⚠️ Error parseando hora "$timeStr": $e');
      return null;
    }
  }

  /// Calcula la próxima instancia de una hora específica
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    // Usar DateTime.now() local del dispositivo directamente
    final localNow = DateTime.now();
    final now = tz.TZDateTime.from(localNow, tz.local);

    debugPrint('⏰ Calculando próxima instancia de $hour:${minute.toString().padLeft(2, '0')}');
    debugPrint('   Hora LOCAL del dispositivo (DateTime.now()): ${localNow.hour}:${localNow.minute}:${localNow.second}');
    debugPrint('   Hora TZ convertida: ${now.hour}:${now.minute}:${now.second}');
    debugPrint('   Zona horaria configurada: ${tz.local.name}');

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0, // segundos
      0, // milisegundos
    );

    debugPrint('   Fecha calculada inicialmente: $scheduledDate');
    debugPrint('   ¿Es antes de ahora? ${scheduledDate.isBefore(now)}');

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('   ⏭️ Hora ya pasó, programando para mañana: $scheduledDate');
    } else {
      debugPrint('   ✅ Programando para hoy: $scheduledDate');
    }

    // Calcular cuánto tiempo falta
    final difference = scheduledDate.difference(now);
    debugPrint('   ⏳ Tiempo hasta la notificación: ${difference.inMinutes} minutos');

    return scheduledDate;
  }

  /// Genera un ID único para la notificación basado en el ID del hábito
  int _getNotificationId(String habitId) {
    // Convertir el hash del ID a un int de 32 bits
    return habitId.hashCode & 0x7FFFFFFF;
  }

  /// Obtiene todas las notificaciones pendientes (útil para debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    return await _notifications.pendingNotificationRequests();
  }

  /// Detecta la zona horaria local usando el offset del dispositivo
  String _detectLocalTimezone() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;

    debugPrint('🕐 Offset del dispositivo: ${offset.inHours} horas');

    // Colombia está en UTC-5 (America/Bogota)
    // Mapear offsets comunes a zonas horarias
    final offsetHours = offset.inHours;

    switch (offsetHours) {
      case -5:
        return 'America/Bogota';
      case -4:
        return 'America/Caracas';
      case -6:
        return 'America/Mexico_City';
      case -3:
        return 'America/Sao_Paulo';
      case 0:
        return 'UTC';
      case 1:
        return 'Europe/Madrid';
      case -8:
        return 'America/Los_Angeles';
      case -7:
        return 'America/Denver';
      default:
        // Si no coincide con ninguno conocido, buscar en la base de datos de zonas
        // horarias una que coincida con el offset
        debugPrint('⚠️ Offset no común: $offsetHours horas. Buscando zona horaria...');
        return _findTimezoneByOffset(offsetHours);
    }
  }

  /// Busca una zona horaria que coincida con el offset dado
  String _findTimezoneByOffset(int offsetHours) {
    // Lista de zonas horarias comunes organizadas por offset
    final timezonesByOffset = {
      -12: 'Pacific/Fiji',
      -11: 'Pacific/Samoa',
      -10: 'Pacific/Honolulu',
      -9: 'America/Anchorage',
      -8: 'America/Los_Angeles',
      -7: 'America/Denver',
      -6: 'America/Chicago',
      -5: 'America/Bogota',  // Colombia es UTC-5
      -4: 'America/Caracas',
      -3: 'America/Sao_Paulo',
      -2: 'Atlantic/South_Georgia',
      -1: 'Atlantic/Azores',
      0: 'UTC',
      1: 'Europe/London',
      2: 'Europe/Paris',
      3: 'Europe/Moscow',
      4: 'Asia/Dubai',
      5: 'Asia/Karachi',
      6: 'Asia/Dhaka',
      7: 'Asia/Bangkok',
      8: 'Asia/Singapore',
      9: 'Asia/Tokyo',
      10: 'Australia/Sydney',
      11: 'Pacific/Noumea',
      12: 'Pacific/Auckland',
    };

    final timezone = timezonesByOffset[offsetHours] ?? 'UTC';
    debugPrint('   Usando zona horaria: $timezone');
    return timezone;
  }
}
