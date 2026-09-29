import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/alerts/data/alerts_coordinator.dart';
import 'package:ciclotrack/features/alerts/data/notification_scheduler.dart';
import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/alerts/presentation/providers/alerts_providers.dart';
import 'package:ciclotrack/features/alerts/presentation/screens/alerts_screen.dart';

import '../../../support/widget_harness.dart';

/// Scheduler falso con permiso configurable.
class _FakeScheduler implements NotificationScheduler {
  _FakeScheduler({required this.permissionGranted});

  final bool permissionGranted;
  int permissionRequests = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> schedule(AlertItem item) async {}

  @override
  Future<void> cancel(List<int> ids) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<PendingNotification>> pending() async => const [];
}

/// Coordinador que no arranca streams ni timers y cuenta los refrescos.
class _RecordingCoordinator extends AlertsCoordinator {
  _RecordingCoordinator({
    required super.scheduler,
    required super.repository,
    required super.changeDao,
  });

  int refreshes = 0;

  @override
  Future<void> start() async {}

  @override
  Future<void> refreshNow() async {
    refreshes++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late AppDatabase db;
  _RecordingCoordinator? coordinator;

  Future<_FakeScheduler> pumpAlerts(
    WidgetTester tester, {
    required bool permissionGranted,
    required bool masterEnabled,
  }) async {
    db = createTestDatabase();
    await seedAlertSettings(tester, db, masterEnabled: masterEnabled);
    final scheduler = _FakeScheduler(permissionGranted: permissionGranted);

    await pumpScreen(
      tester,
      db,
      const AlertsScreen(),
      overrides: [
        notificationSchedulerProvider.overrideWithValue(scheduler),
        alertsCoordinatorProvider.overrideWith((ref) {
          return coordinator = _RecordingCoordinator(
            scheduler: ref.watch(notificationSchedulerProvider),
            repository: ref.watch(alertsRepositoryProvider),
            changeDao: ref.watch(alertsChangeDaoProvider),
          );
        }),
      ],
    );
    return scheduler;
  }

  testWidgets('master switch stays off when the permission is denied', (
    tester,
  ) async {
    final scheduler = await pumpAlerts(
      tester,
      permissionGranted: false,
      masterEnabled: false,
    );

    await tester.tap(find.byType(SwitchListTile));
    await pumpStreams(tester);

    expect(find.text('Permiso de notificaciones no concedido'), findsOneWidget);
    expect(scheduler.permissionRequests, 1);
    expect(coordinator?.refreshes ?? 0, 0);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    final settings = await runReal(
      tester,
      () => AlertSettingsDao(db).getOrCreate(),
    );
    expect(settings.masterEnabled, isFalse);

    await closeTestDatabase(tester, db);
  });

  testWidgets('master switch is enabled and refreshes when permission is '
      'granted', (tester) async {
    final scheduler = await pumpAlerts(
      tester,
      permissionGranted: true,
      masterEnabled: false,
    );

    await tester.tap(find.byType(SwitchListTile));
    await pumpStreams(tester);

    expect(scheduler.permissionRequests, 1);
    expect(coordinator!.refreshes, 1);
    expect(find.text('Permiso de notificaciones no concedido'), findsNothing);
    final settings = await runReal(
      tester,
      () => AlertSettingsDao(db).getOrCreate(),
    );
    expect(settings.masterEnabled, isTrue);

    await closeTestDatabase(tester, db);
  });

  testWidgets('disabling the master switch does not ask for permission', (
    tester,
  ) async {
    final scheduler = await pumpAlerts(
      tester,
      permissionGranted: true,
      masterEnabled: true,
    );

    await tester.tap(find.byType(SwitchListTile));
    await pumpStreams(tester);

    expect(scheduler.permissionRequests, 0);
    expect(coordinator!.refreshes, 1);
    final settings = await runReal(
      tester,
      () => AlertSettingsDao(db).getOrCreate(),
    );
    expect(settings.masterEnabled, isFalse);

    await closeTestDatabase(tester, db);
  });
}
