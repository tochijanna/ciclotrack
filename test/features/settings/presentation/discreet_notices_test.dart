import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/core/l10n/app_locale.dart';
import 'package:ciclotrack/core/privacy/discreet_notices.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/alerts/data/notification_scheduler.dart';
import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/alerts/presentation/providers/alerts_providers.dart';
import 'package:ciclotrack/features/medications/data/medication_dao.dart';
import 'package:ciclotrack/features/settings/presentation/providers/discreet_notices_provider.dart';
import 'package:ciclotrack/features/settings/presentation/providers/reminder_providers.dart';

import '../../../support/fake_reminder_notifier.dart';

class _Scheduler implements NotificationScheduler {
  final notifications = <int, PendingNotification>{};

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> canScheduleExact() async => true;
  @override
  Future<List<PendingNotification>> pending() async => [
    ...notifications.values,
  ];
  @override
  Future<void> schedule(AlertItem item, String title, String body) async {
    notifications[item.id] = PendingNotification(
      id: item.id,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(List<int> ids) async => ids.forEach(notifications.remove);
  @override
  Future<void> cancelAll() async => notifications.clear();
}

void main() {
  // El coordinador de alertas crea un `AppLifecycleListener`.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PRIV-05: cambiar el ajuste reprograma los avisos pendientes', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final scheduler = _Scheduler();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appLocaleProvider.overrideWithValue(const Locale('es')),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        reminderNotifierProvider.overrideWithValue(FakeReminderNotifier()),
      ],
    );
    try {
      final settingsDao = AlertSettingsDao(db);
      final settings = await settingsDao.getOrCreate();
      await settingsDao.updateSettings(
        settings.copyWith(masterEnabled: true, enabledTypes: 'medicacion'),
      );
      final womanId = await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: 'María',
              initials: 'MR',
              createdAt: DateTime(2026, 9, 10),
            ),
          );
      await MedicationDao(db).insert(
        MedicationsCompanion.insert(
          womanId: womanId,
          name: 'Hierro',
          hour: 12,
          minute: 0,
        ),
      );

      /// Espera a que el coordinador deje el aviso con el título esperado.
      Future<PendingNotification> pendingWithTitle(String title) async {
        for (var i = 0; i < 100; i++) {
          final found = scheduler.notifications.values.where(
            (n) => n.title == title,
          );
          if (found.isNotEmpty) return found.single;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        fail('Sin aviso «$title»: ${scheduler.notifications.values}');
      }

      // Privado por defecto: sin preferencia guardada el aviso es genérico.
      expect(container.read(discreetNoticesProvider), isTrue);
      container.read(alertsCoordinatorProvider);
      final generic = await pendingWithTitle(discreetNoticeTitle);
      expect(generic.body, 'Tienes un aviso nuevo. Abre la app para verlo.');

      await container.read(discreetNoticesProvider.notifier).setEnabled(false);
      final detailed = await pendingWithTitle('Medicación');
      expect(detailed.id, generic.id);
      expect(scheduler.notifications, hasLength(1));
      expect(await readDiscreetNotices(), isFalse);
    } finally {
      container.dispose();
      // Deja vencer el debounce de los coordinadores antes de cerrar la base.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await db.close();
    }
  });
}
