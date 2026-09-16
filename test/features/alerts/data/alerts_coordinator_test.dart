import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/alerts/data/alerts_change_dao.dart';
import 'package:ciclotrack/features/alerts/data/alerts_coordinator.dart';
import 'package:ciclotrack/features/alerts/data/alerts_repository.dart';
import 'package:ciclotrack/features/alerts/data/notification_scheduler.dart';
import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/alerts/domain/alert_types.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/prediction/data/prediction_dao.dart';
import 'package:ciclotrack/features/prediction/data/prediction_repository.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_engine.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late AlertSettingsDao settingsDao;
  late AlertsCoordinator coordinator;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    settingsDao = AlertSettingsDao(db);

    final predictionRepo = PredictionRepository(
      PredictionDao(db),
      calculator: PredictionCalculator(engine: PredictionEngine()),
    );
    final encounterRepo = EncounterRepository(EncounterDao(db));
    final womenRepo = WomenRepository(WomenDao(db));
    final repository = AlertsRepository(
      scheduler: scheduler,
      settingsDao: settingsDao,
      predictionRepo: predictionRepo,
      encounterRepo: encounterRepo,
      womenRepo: womenRepo,
    );
    coordinator = AlertsCoordinator(
      scheduler: scheduler,
      repository: repository,
      changeDao: AlertsChangeDao(db),
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await db.close();
  });

  test('initializes scheduler and keeps new installations disabled', () async {
    await coordinator.start();

    expect(scheduler.initializeCalls, 1);
    expect(scheduler.cancelCalls, greaterThanOrEqualTo(1));
    expect((await settingsDao.getOrCreate()).masterEnabled, isFalse);
  });

  test('refreshes after a relevant period change', () async {
    final settings = await settingsDao.getOrCreate();
    await settingsDao.updateSettings(
      settings.copyWith(
        masterEnabled: true,
        enabledTypes: AlertType.values.map((t) => t.name).join(','),
      ),
    );
    await coordinator.start();
    final cancelsBefore = scheduler.cancelCalls;

    final womanId = await WomenRepository(
      WomenDao(db),
    ).create(const WomanDraft(name: 'María', initials: 'MR'));
    await TrackingRepository(
      TrackingDao(db),
    ).createPeriod(womanId, PeriodDraft(startDate: DateTime(2026, 9, 1)));
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(scheduler.cancelCalls, greaterThan(cancelsBefore));
  });

  test(
    'disabling master cancels pending notifications after refresh',
    () async {
      final settings = await settingsDao.getOrCreate();
      await settingsDao.updateSettings(settings.copyWith(masterEnabled: true));
      await coordinator.start();
      final cancelsBefore = scheduler.cancelCalls;

      await settingsDao.updateSettings(settings.copyWith(masterEnabled: false));
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(scheduler.cancelCalls, greaterThan(cancelsBefore));
    },
  );
}

class FakeNotificationScheduler implements NotificationScheduler {
  int initializeCalls = 0;
  int requestPermissionCalls = 0;
  int cancelCalls = 0;
  final scheduled = <AlertItem>[];

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalls++;
    return true;
  }

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> schedule(AlertItem item) async {
    scheduled.add(item);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled.clear();
  }

  @override
  Future<List<PendingNotification>> pending() async => const [];
}
