import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/app_database_provider.dart';
import '../../../encounters/data/encounter_dao.dart';
import '../../../encounters/data/encounter_repository.dart';
import '../../../prediction/data/prediction_dao.dart';
import '../../../prediction/data/prediction_repository.dart';
import '../../../prediction/domain/prediction_calculator.dart';
import '../../../prediction/domain/prediction_engine.dart';
import '../../../profiles/data/women_dao.dart';
import '../../../profiles/data/women_repository.dart';
import '../../domain/alert_item.dart';
import '../../domain/alert_rule_engine.dart';
import '../../data/alert_settings_dao.dart';
import '../../data/alerts_change_dao.dart';
import '../../data/alerts_coordinator.dart';
import '../../data/alerts_repository.dart';
import '../../data/notification_scheduler.dart';
import '../../data/local_notification_scheduler.dart';

// --- Providers base ---

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final plugin = FlutterLocalNotificationsPlugin();
  return LocalNotificationScheduler(plugin);
});

final alertSettingsDaoProvider = Provider<AlertSettingsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AlertSettingsDao(db);
});

final alertsChangeDaoProvider = Provider<AlertsChangeDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AlertsChangeDao(db);
});

final alertRuleEngineProvider = Provider<AlertRuleEngine>((ref) {
  return const AlertRuleEngine();
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final predictionRepo = PredictionRepository(
    PredictionDao(db),
    calculator: PredictionCalculator(engine: PredictionEngine()),
  );
  final encounterRepo = EncounterRepository(EncounterDao(db));
  final womenRepo = WomenRepository(WomenDao(db));

  return AlertsRepository(
    scheduler: ref.watch(notificationSchedulerProvider),
    settingsDao: ref.watch(alertSettingsDaoProvider),
    predictionRepo: predictionRepo,
    encounterRepo: encounterRepo,
    womenRepo: womenRepo,
    engine: ref.watch(alertRuleEngineProvider),
  );
});

final alertsCoordinatorProvider = Provider<AlertsCoordinator>((ref) {
  final coordinator = AlertsCoordinator(
    scheduler: ref.watch(notificationSchedulerProvider),
    repository: ref.watch(alertsRepositoryProvider),
    changeDao: ref.watch(alertsChangeDaoProvider),
  );
  unawaited(coordinator.start());
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

// --- Ajustes ---

final alertSettingsStreamProvider = StreamProvider.autoDispose<AlertSetting?>((
  ref,
) {
  final dao = ref.watch(alertSettingsDaoProvider);
  unawaited(dao.ensureCreated());
  return dao.watchSettings();
});

// --- Vista previa de alertas ---

final upcomingAlertsProvider = FutureProvider.autoDispose<List<AlertItem>>((
  ref,
) async {
  final repo = ref.watch(alertsRepositoryProvider);
  return repo.watchUpcomingAlerts();
});
