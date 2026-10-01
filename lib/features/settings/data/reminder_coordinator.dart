import 'dart:async';

import '../../alerts/data/alerts_change_dao.dart';
import 'reminder_notifier.dart';
import 'reminder_scheduler.dart';

/// Reprograma los recordatorios al arrancar y cuando cambian los periodos o
/// la hora de aviso.
class ReminderCoordinator {
  ReminderCoordinator({
    required this.notifier,
    required this.scheduler,
    required this.changeDao,
    required this.now,
  });

  final ReminderNotifier notifier;
  final ReminderScheduler scheduler;
  final AlertsChangeDao changeDao;
  final DateTime Function() now;

  StreamSubscription<void>? _changesSubscription;
  Timer? _debounce;
  bool _refreshing = false;
  bool _refreshQueued = false;
  bool _started = false;
  bool _disposed = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await notifier.initialize();
    await refreshNow();
    if (_disposed) return;
    _changesSubscription = changeDao.watchRelevantChanges().listen((_) {
      _scheduleRefresh();
    });
  }

  Future<void> refreshNow() async {
    if (_refreshing) {
      _refreshQueued = true;
      return;
    }
    _refreshing = true;
    try {
      await scheduler.refresh(today: now());
    } catch (_) {
      // Los recordatorios no deben bloquear la UI ni el arranque.
    } finally {
      _refreshing = false;
      if (_refreshQueued) {
        _refreshQueued = false;
        _scheduleRefresh();
      }
    }
  }

  void _scheduleRefresh() {
    if (_disposed) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), refreshNow);
  }

  Future<void> dispose() async {
    _disposed = true;
    _debounce?.cancel();
    await _changesSubscription?.cancel();
  }
}
