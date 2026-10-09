import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;

import 'alerts_change_dao.dart';
import 'alerts_repository.dart';
import 'notification_scheduler.dart';

/// Inicializa alertas y reprograma cuando cambia cualquier dato relevante.
class AlertsCoordinator {
  AlertsCoordinator({
    required this.scheduler,
    required this.repository,
    required this.changeDao,
  });

  final NotificationScheduler scheduler;
  final AlertsRepository repository;
  final AlertsChangeDao changeDao;

  StreamSubscription<void>? _changesSubscription;
  Timer? _debounce;
  bool _refreshing = false;
  bool _refreshQueued = false;
  bool _started = false;

  /// Momento del último refresco fallido, `null` si el último fue correcto.
  DateTime? lastRefreshFailure;

  /// Tipo del último error (solo identificador, sin mensaje ni datos).
  String? lastErrorKind;
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await scheduler.initialize();
    await refreshNow();
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
      await repository.refreshAlerts();
      lastRefreshFailure = null;
      lastErrorKind = null;
    } catch (e) {
      // Las alertas no deben bloquear la UI ni el arranque de la aplicación.
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), refreshNow);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _changesSubscription?.cancel();
  }
}
