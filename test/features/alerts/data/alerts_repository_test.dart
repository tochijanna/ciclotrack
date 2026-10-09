import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/alerts/data/alerts_repository.dart';
import 'package:ciclotrack/features/alerts/data/notification_scheduler.dart';
import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/medications/data/medication_dao.dart';
import 'package:ciclotrack/features/prediction/data/prediction_dao.dart';
import 'package:ciclotrack/features/prediction/data/prediction_repository.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _Scheduler implements NotificationScheduler {
  final notifications = <PendingNotification>[
    const PendingNotification(
      id: alertNotificationIdBase,
      title: 'Alerta obsoleta',
      body: '',
    ),
    const PendingNotification(id: 1000003, title: 'Recordatorio', body: ''),
    const PendingNotification(id: 42, title: 'Otro pendiente', body: ''),
  ];
  final cancelled = <int>[];
  final scheduled = <AlertItem>[];
  int cancelAllCalls = 0;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> canScheduleExact() async => true;
  @override
  Future<List<PendingNotification>> pending() async => [...notifications];
  @override
  Future<void> schedule(AlertItem item, String title, String body) async {
    scheduled.add(item);
    notifications.removeWhere((n) => n.id == item.id);
    notifications.add(
      PendingNotification(id: item.id, title: title, body: body),
    );
  }

  @override
  Future<void> cancel(List<int> ids) async {
    cancelled.addAll(ids);
    notifications.removeWhere((n) => ids.contains(n.id));
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    notifications.clear();
  }
}

void main() {
  for (final masterEnabled in [true, false]) {
    test('conserva pendientes ajenos con maestro $masterEnabled', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final scheduler = _Scheduler();
        final settingsDao = AlertSettingsDao(db);
        final settings = await settingsDao.getOrCreate();
        await settingsDao.updateSettings(
          settings.copyWith(
            masterEnabled: masterEnabled,
            enabledTypes: 'medicacion',
          ),
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
        final repo = AlertsRepository(
          scheduler: scheduler,
          settingsDao: settingsDao,
          predictionRepo: PredictionRepository(PredictionDao(db)),
          encounterRepo: EncounterRepository(EncounterDao(db)),
          womenRepo: WomenRepository(WomenDao(db)),
          medicationDao: MedicationDao(db),
          l10n: lookupAppLocalizations(const Locale('es')),
        );
        await repo.refreshAlerts(today: DateTime(2026, 9, 10, 10));
        expect(scheduler.cancelAllCalls, 0);
        expect(scheduler.cancelled, [alertNotificationIdBase]);
        expect(
          scheduler.notifications.map((n) => n.id),
          containsAll([1000003, 42]),
        );
        if (masterEnabled) {
          expect(scheduler.scheduled, hasLength(1));
          expect(
            scheduler.notifications.map((n) => n.id),
            contains(scheduler.scheduled.single.id),
          );
          scheduler.cancelled.clear();
          await repo.refreshAlerts(today: DateTime(2026, 9, 10, 10));
          expect(scheduler.cancelled, isEmpty);
        } else {
          expect(scheduler.scheduled, isEmpty);
          expect(scheduler.notifications, hasLength(2));
        }
      } finally {
        await db.close();
      }
    });
  }

  test('PRIV-04/05: los avisos discretos no llevan tipo ni datos', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final scheduler = _Scheduler()..notifications.clear();
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
      var discreet = true;
      final repo = AlertsRepository(
        scheduler: scheduler,
        settingsDao: settingsDao,
        predictionRepo: PredictionRepository(PredictionDao(db)),
        encounterRepo: EncounterRepository(EncounterDao(db)),
        womenRepo: WomenRepository(WomenDao(db)),
        medicationDao: MedicationDao(db),
        l10n: lookupAppLocalizations(const Locale('es')),
        discreet: () async => discreet,
      );

      await repo.refreshAlerts(today: DateTime(2026, 9, 10, 10));
      var pending = scheduler.notifications.single;
      expect(pending.title, 'CicloTrack');
      expect(pending.body, 'Tienes un aviso nuevo. Abre la app para verlo.');

      // Al cambiar el ajuste, el mismo aviso pendiente se reescribe.
      discreet = false;
      await repo.refreshAlerts(today: DateTime(2026, 9, 10, 10));
      final id = pending.id;
      pending = scheduler.notifications.single;
      expect(pending.id, id);
      expect(pending.title, 'Medicación');
      expect(pending.body, 'Es hora de tu medicación (12:00)');
    } finally {
      await db.close();
    }
  });
}
