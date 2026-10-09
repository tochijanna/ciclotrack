import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;

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
  bool _disposed = false;
  bool _started = false;

  /// Momento del último refresco fallido, `null` si el último fue correcto.
  DateTime? lastRefreshFailure;

  /// Tipo del último error (solo identificador, sin mensaje ni datos).
  String? lastErrorKind;

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
      lastRefreshFailure = null;
      lastErrorKind = null;
    } catch (e) {
      // Los recordatorios no deben bloquear la UI ni el arranque.
      // Diagnóstico sin contenido sensible: solo el tipo (y código, si lo hay).
      lastErrorKind = e is PlatformException
          ? 'PlatformException(${e.code})'
          : e.runtimeType.toString();
      lastRefreshFailure = DateTime.now();
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
