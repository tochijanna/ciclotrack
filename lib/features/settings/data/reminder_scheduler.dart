import 'package:ciclotrack/l10n/app_localizations.dart';

import '../../../core/privacy/discreet_notices.dart';
import '../../alerts/data/alert_settings_dao.dart';
import '../../prediction/data/prediction_dao.dart';
import '../../prediction/domain/prediction_engine.dart';
import '../domain/reminder_validators.dart';
import 'reminder_notifier.dart';
import 'reminder_repository.dart';
import 'reminder_text.dart';

/// Programa una notificación por ciclo para cada recordatorio activo.
class ReminderScheduler {
  ReminderScheduler({
    required this.notifier,
    required this.repository,
    required this.predictionDao,
    required this.settingsDao,
    required this.l10n,
    this.discreet = readDiscreetNotices,
    PredictionEngine? engine,
  }) : _engine = engine ?? PredictionEngine();

  static const int _defaultNotifyHour = 9;
  static const int _defaultNotifyMinute = 0;

  final ReminderNotifier notifier;
  final ReminderRepository repository;
  final PredictionDao predictionDao;
  final AlertSettingsDao settingsDao;
  final AppLocalizations l10n;

  /// Si los avisos se programan con texto genérico (PRIV-04).
  final Future<bool> Function() discreet;
  final PredictionEngine _engine;

  /// Id estable de la notificación de un recordatorio: al cambiar la fecha se
  /// reprograma sobre el mismo id y no quedan avisos duplicados.
  static int notificationId(int reminderId) =>
      reminderNotificationIdBase + reminderId;

  /// Recalcula y reprograma la próxima ocurrencia de cada recordatorio activo.
  Future<void> refresh({required DateTime today}) async {
    final settings = await settingsDao.watchSettings().first;
    final hour = settings?.notifyHour ?? _defaultNotifyHour;
    final minute = settings?.notifyMinute ?? _defaultNotifyMinute;

    final generic = await discreet();
    final reminders = await repository.watchActive().first;
    final cycles = <int, _WomanCycle>{};
    final newIds = <int>{};

    // Programar primero; así un fallo no deja al usuario sin las anteriores.
    for (final reminder in reminders) {
      final cycle = cycles[reminder.womanId] ??= await _cycleOf(
        reminder.womanId,
      );
      final when = nextReminderFire(
        lastPeriodStart: cycle.lastPeriodStart,
        cycleDay: reminder.cycleDayStart,
        now: today,
        cycleLength: cycle.length,
        hour: hour,
        minute: minute,
      );
      if (when == null) continue;

      final id = notificationId(reminder.id);
      await notifier.schedule(
        id: id,
        when: when,
        title: generic ? discreetNoticeTitle : l10n.reminderNotificationTitle,
        body: generic
            ? l10n.discreetNoticeBody
            : reminderNotificationBody(l10n, reminder),
      );
      newIds.add(id);
    }

    final pending = (await notifier.pendingIds()).toSet();
    await notifier.cancel(pending.difference(newIds).toList());
  }

  /// Cancela todas las notificaciones de recordatorio pendientes.
  Future<void> cancelAll() async {
    await notifier.cancel(await notifier.pendingIds());
  }

  Future<_WomanCycle> _cycleOf(int womanId) async {
    final logs = await predictionDao.watchPeriodLogsByWoman(womanId).first;
    final starts = logs.map((log) => log.startDate).toList();
    final average = _engine
        .predict(cycleLengths: _engine.cycleLengthsFrom(starts))
        .averageCycle;
    return _WomanCycle(
      lastPeriodStart: starts.isEmpty ? null : starts.last,
      length: average.round(),
    );
  }
}

class _WomanCycle {
  const _WomanCycle({required this.lastPeriodStart, required this.length});

  final DateTime? lastPeriodStart;
  final int length;
}
