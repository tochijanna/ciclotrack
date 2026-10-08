import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_notifier.dart';

/// Implementación de [ReminderNotifier] con flutter_local_notifications.
class LocalReminderNotifier implements ReminderNotifier {
  LocalReminderNotifier(this._plugin, this._l10n);

  /// Marca las notificaciones propias para distinguirlas de las alertas, que
  /// comparten plugin.
  static const String payload = 'ciclotrack_reminder';

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;
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
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!_available) return;
    final tzDateTime = tz.TZDateTime.from(when, tz.local);

    // Si la fecha ya pasó, no programar.
    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'recordatorios',
      _l10n.reminderChannelName,
      channelDescription: _l10n.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.secret,
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
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDateTime,
      notificationDetails: details,
      androidScheduleMode: mode,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(List<int> ids) async {
    await initialize();
    if (!_available) return;
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }

  @override
  Future<List<int>> pendingIds() async {
    await initialize();
    if (!_available) return const [];
    final pending = await _plugin.pendingNotificationRequests();
    return pending.where((p) => p.payload == payload).map((p) => p.id).toList();
  }
}
