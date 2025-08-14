import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(init);

    // 👉 Android 13+: pedir permiso de notificaciones
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    // 👉 Android 12+: permiso para alarmas exactas (opcional, recomendado)
    await androidImpl?.requestExactAlarmsPermission();

    // 👉 iOS: ya se solicitaron arriba con DarwinInitializationSettings
  }

  Future<bool> ensureAndroidPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.areNotificationsEnabled() ?? true;
    if (!granted) {
      // intenta solicitar nuevamente
      return await androidImpl?.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  Future<bool> scheduleReminder({
    required int id,
    required DateTime citaDateTime,
    required String title,
    required String body,
  }) async {
    final ok = await ensureAndroidPermission();
    if (!ok) return false;

    final reminder = citaDateTime.subtract(const Duration(days: 1));
    if (reminder.isBefore(DateTime.now())) return false;

    final when = tz.TZDateTime.from(reminder, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'citas_channel', 'Recordatorios de Citas',
      channelDescription: 'Recordatorios 24h antes de la cita',
      importance: Importance.high, priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id, title, body, when, details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
    return true;
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
