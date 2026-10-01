import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../../../core/time/clock.dart';
import '../../../alerts/data/alert_settings_dao.dart';
import '../../../alerts/data/alerts_change_dao.dart';
import '../../../prediction/data/prediction_dao.dart';
import '../../data/local_reminder_notifier.dart';
import '../../data/reminder_coordinator.dart';
import '../../data/reminder_dao.dart';
import '../../data/reminder_notifier.dart';
import '../../data/reminder_repository.dart';
import '../../data/reminder_scheduler.dart';
import '../../domain/reminder_validators.dart';

// --- Providers base ---

final reminderDaoProvider = Provider<ReminderDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReminderDao(db);
});

final reminderNotifierProvider = Provider<ReminderNotifier>((ref) {
  final plugin = FlutterLocalNotificationsPlugin();
  return LocalReminderNotifier(plugin);
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReminderScheduler(
    notifier: ref.watch(reminderNotifierProvider),
    repository: ReminderRepository(ref.watch(reminderDaoProvider)),
    predictionDao: PredictionDao(db),
    settingsDao: AlertSettingsDao(db),
  );
});

/// Repositorio de la UI: cada escritura reprograma las notificaciones.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);
  final clock = ref.watch(clockProvider);
  return ReminderRepository(
    ref.watch(reminderDaoProvider),
    onChanged: () => scheduler.refresh(today: clock.now()),
  );
});

final reminderCoordinatorProvider = Provider<ReminderCoordinator>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  final coordinator = ReminderCoordinator(
    notifier: ref.watch(reminderNotifierProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
    changeDao: AlertsChangeDao(db),
    now: clock.now,
  );
  unawaited(coordinator.start());
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

// --- Streams ---

final remindersByWomanProvider = StreamProvider.autoDispose
    .family<List<CycleReminder>, int>((ref, womanId) {
      final repo = ref.watch(reminderRepositoryProvider);
      return repo.watchByWoman(womanId);
    });

final activeRemindersProvider = StreamProvider.autoDispose<List<CycleReminder>>(
  (ref) {
    final repo = ref.watch(reminderRepositoryProvider);
    return repo.watchActive();
  },
);
