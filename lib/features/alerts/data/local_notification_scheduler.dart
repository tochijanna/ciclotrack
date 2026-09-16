import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../domain/alert_item.dart';
import 'notification_scheduler.dart';

/// Implementación de [NotificationScheduler] con flutter_local_notifications.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;
  bool _available = true;

  @override
  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      tz.initializeTimeZones();
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(settings: initSettings);
    } catch (_) {
      // Widget/unit tests and unsupported platforms have no plugin channel.
      _available = false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (!_available) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<bool> canScheduleExact() async {
    await initialize();
    if (!_available) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    return await android.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> schedule(AlertItem item) async {
    await initialize();
    if (!_available) return;
    final tzDateTime = tz.TZDateTime.from(item.fireDate, tz.local);

    // Si la fecha ya pasó, no programar.
    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'ciclotrack_alerts',
      'Alertas de CicloTrack',
      channelDescription: 'Notificaciones de fertilidad y ciclo',
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    // Intentar programar con alarma exacta; fallback a inexacta.
    AndroidScheduleMode mode;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canExact =
          android != null &&
          (await android.canScheduleExactNotifications() ?? false);
      mode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      mode = AndroidScheduleMode.inexactAllowWhileIdle;
    }

    await _plugin.zonedSchedule(
      id: item.id,
      title: item.title,
      body: item.body,
      scheduledDate: tzDateTime,
      notificationDetails: details,
      androidScheduleMode: mode,
    );
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    if (!_available) return;
    await _plugin.cancelAll();
  }

  @override
  Future<List<PendingNotification>> pending() async {
    await initialize();
    if (!_available) return const [];
    final pending = await _plugin.pendingNotificationRequests();
    return pending
        .map(
          (p) => PendingNotification(
            id: p.id,
            title: p.title ?? '',
            body: p.body ?? '',
          ),
        )
        .toList();
  }
}
