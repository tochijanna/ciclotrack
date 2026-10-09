import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:ciclotrack/features/alerts/data/local_notification_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plugin Android falso: `initialize` falla N veces antes de funcionar.
class _FlakyAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  _FlakyAndroidPlugin(this.failuresLeft);

  int failuresLeft;
  int initializeCalls = 0;

  @override
  Future<bool> initialize({
    required AndroidInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalls++;
    if (failuresLeft > 0) {
      failuresLeft--;
      throw StateError('transient');
    }
    return true;
  }

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LocalNotificationScheduler build(_FlakyAndroidPlugin plugin) =>
      LocalNotificationScheduler(
        FlutterLocalNotificationsPlugin(),
        lookupAppLocalizations(const Locale('es')),
        timezoneId: () async => 'Europe/Madrid',
      );

  test('un fallo transitorio se recupera en el siguiente intento', () async {
    final plugin = _FlakyAndroidPlugin(1);
    FlutterLocalNotificationsPlatform.instance = plugin;
    addTearDown(
      () => FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin(),
    );
    final scheduler = build(plugin);

    await scheduler.initialize();
    expect(scheduler.isAvailable, false, reason: 'primer intento falla');
    expect(plugin.initializeCalls, 1);

    // La próxima operación reintenta la inicialización y funciona.
    await scheduler.initialize();
    expect(scheduler.isAvailable, true);
    expect(plugin.initializeCalls, 2);

    // Ya inicializado: no reintenta de más.
    await scheduler.pending();
    expect(plugin.initializeCalls, 2);
    expect(await scheduler.pending(), isEmpty);
  });

  test('un fallo persistente deja el scheduler no disponible', () async {
    final plugin = _FlakyAndroidPlugin(99);
    FlutterLocalNotificationsPlatform.instance = plugin;
    addTearDown(
      () => FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin(),
    );
    final scheduler = build(plugin);

    await scheduler.initialize();
    await scheduler.pending();
    expect(scheduler.isAvailable, false);
    expect(plugin.initializeCalls, 2, reason: 'cada operación reintenta');
    expect(await scheduler.pending(), isEmpty);
  });
}
