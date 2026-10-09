import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/alerts/data/alerts_change_dao.dart';
import 'package:ciclotrack/features/prediction/data/prediction_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/settings/data/reminder_coordinator.dart';
import 'package:ciclotrack/features/settings/data/reminder_dao.dart';
import 'package:ciclotrack/features/settings/data/reminder_notifier.dart';
import 'package:ciclotrack/features/settings/data/reminder_repository.dart';
import 'package:ciclotrack/features/settings/data/reminder_scheduler.dart';
import 'package:ciclotrack/features/settings/domain/reminder_validators.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

import '../../../support/fake_reminder_notifier.dart';

void main() {
  late AppDatabase db;
  late FakeReminderNotifier notifier;
  late ReminderRepository repo;
  late ReminderScheduler scheduler;
  late bool discreet;
  late TrackingRepository tracking;
  late int womanId;

  const draft = ReminderDraft(
    message: 'Mejor evitar sexo',
    cycleDayStart: 5,
    cycleDayEnd: 7,
  );

  Future<void> setNotifyTime(int hour, int minute) async {
    final dao = AlertSettingsDao(db);
    final row = await dao.getOrCreate();
    await dao.updateSettings(
      row.copyWith(notifyHour: hour, notifyMinute: minute),
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notifier = FakeReminderNotifier();
    repo = ReminderRepository(ReminderDao(db));
    discreet = false;
    scheduler = ReminderScheduler(
      discreet: () async => discreet,
      notifier: notifier,
      repository: repo,
      predictionDao: PredictionDao(db),
      settingsDao: AlertSettingsDao(db),
      l10n: lookupAppLocalizations(const Locale('es')),
    );
    tracking = TrackingRepository(TrackingDao(db));
    womanId = await WomenRepository(
      WomenDao(db),
    ).create(const WomanDraft(name: 'María', initials: 'MR'));
  });

  tearDown(() async {
    await db.close();
  });

  test('reserves notification ids from 1000000 upwards', () {
    expect(reminderNotificationIdBase, 1000000);
    expect(ReminderScheduler.notificationId(7), 1000007);
  });

  test(
    'schedules one notification on cycle day 5 at the notify time',
    () async {
      await setNotifyTime(20, 15);
      await tracking.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      final id = await repo.create(womanId, draft);

      await scheduler.refresh(today: DateTime(2026, 9, 2, 12));

      final item = notifier.scheduled.values.single;
      expect(item.id, 1000000 + id);
      expect(item.when, DateTime(2026, 9, 5, 20, 15));
      expect(item.title, 'Recordatorio');
      expect(item.body, 'Mejor evitar sexo (días 5-7 del ciclo)');
    },
  );

  test('PRIV-04/05: discreet notices hide the reminder text', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    final id = await repo.create(womanId, draft);

    discreet = true;
    await scheduler.refresh(today: DateTime(2026, 9, 2, 12));

    var item = notifier.scheduled.values.single;
    expect(item.id, 1000000 + id);
    expect(item.title, 'CicloTrack');
    expect(item.body, 'Tienes un aviso nuevo. Abre la app para verlo.');

    // Al cambiar el ajuste, el mismo aviso pendiente se reescribe.
    discreet = false;
    await scheduler.refresh(today: DateTime(2026, 9, 2, 12));

    item = notifier.scheduled.values.single;
    expect(item.id, 1000000 + id);
    expect(item.body, 'Mejor evitar sexo (días 5-7 del ciclo)');
  });

  test('uses 09:00 and the plain message without settings or range', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    await repo.create(
      womanId,
      const ReminderDraft(
        message: 'Llevar flores',
        cycleDayStart: 5,
        cycleDayEnd: 5,
      ),
    );

    await scheduler.refresh(today: DateTime(2026, 9, 2));

    final item = notifier.scheduled.values.single;
    expect(item.when, DateTime(2026, 9, 5, 9));
    expect(item.body, 'Llevar flores');
    // Leer la hora de aviso no debe crear la fila de ajustes.
    expect(await db.select(db.alertSettings).get(), isEmpty);
  });

  test('a past occurrence moves to the next default 28-day cycle', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    await repo.create(womanId, draft);

    await scheduler.refresh(today: DateTime(2026, 9, 6));

    expect(notifier.scheduled.values.single.when, DateTime(2026, 10, 3, 9));
  });

  test('projects with the average length of the real cycles', () async {
    for (final start in [
      DateTime(2026, 7, 3),
      DateTime(2026, 8, 2),
      DateTime(2026, 9, 1),
    ]) {
      await tracking.createPeriod(womanId, PeriodDraft(startDate: start));
    }
    await repo.create(womanId, draft);

    await scheduler.refresh(today: DateTime(2026, 9, 6));

    // Ciclos reales de 30 días: 5 sep + 30.
    expect(notifier.scheduled.values.single.when, DateTime(2026, 10, 5, 9));
  });

  test('a disabled reminder schedules nothing', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    await repo.create(
      womanId,
      const ReminderDraft(
        message: 'Mejor evitar sexo',
        cycleDayStart: 5,
        cycleDayEnd: 7,
        enabled: false,
      ),
    );

    await scheduler.refresh(today: DateTime(2026, 9, 2));

    expect(notifier.scheduled, isEmpty);
  });

  test('a woman without periods schedules nothing', () async {
    await repo.create(womanId, draft);

    await scheduler.refresh(today: DateTime(2026, 9, 2));

    expect(notifier.scheduled, isEmpty);
  });

  test('cancels the notifications of disabled and deleted reminders', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    final keptId = await repo.create(womanId, draft);
    final disabledId = await repo.create(womanId, draft);
    final deletedId = await repo.create(womanId, draft);
    await scheduler.refresh(today: DateTime(2026, 9, 2));
    expect(notifier.scheduled, hasLength(3));

    final disabled = (await repo.watchByWoman(womanId).first).firstWhere(
      (r) => r.id == disabledId,
    );
    await repo.setEnabled(disabled, false);
    await repo.delete(deletedId);
    await scheduler.refresh(today: DateTime(2026, 9, 2));

    expect(notifier.scheduled.keys, [1000000 + keptId]);
    expect(
      notifier.cancelledIds,
      unorderedEquals([1000000 + disabledId, 1000000 + deletedId]),
    );
  });

  test('cancelAll removes every pending reminder notification', () async {
    await tracking.createPeriod(
      womanId,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );
    await repo.create(womanId, draft);
    await scheduler.refresh(today: DateTime(2026, 9, 2));

    await scheduler.cancelAll();

    expect(notifier.scheduled, isEmpty);
  });

  group('ReminderCoordinator', () {
    late ReminderCoordinator coordinator;

    setUp(() {
      coordinator = ReminderCoordinator(
        notifier: notifier,
        scheduler: scheduler,
        changeDao: AlertsChangeDao(db),
        now: () => DateTime(2026, 9, 2, 12),
      );
    });

    tearDown(() async {
      await coordinator.dispose();
    });

    test('initializes the notifier and schedules at start-up', () async {
      await tracking.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      await repo.create(womanId, draft);

      await coordinator.start();

      expect(notifier.initializeCalls, 1);
      expect(notifier.scheduled.values.single.when, DateTime(2026, 9, 5, 9));
    });

    test('reschedules when the period changes', () async {
      final periodId = await tracking.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      final id = await repo.create(womanId, draft);
      await coordinator.start();

      await tracking.updatePeriodById(
        periodId,
        PeriodDraft(startDate: DateTime(2026, 9, 2)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final item = notifier.scheduled.values.single;
      expect(item.id, 1000000 + id);
      expect(item.when, DateTime(2026, 9, 6, 9));
    });
  });
}
