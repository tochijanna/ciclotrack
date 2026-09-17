import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final predictionDayProvider = NotifierProvider<PredictionDayNotifier, DateTime>(
  PredictionDayNotifier.new,
);

class PredictionDayNotifier extends Notifier<DateTime> {
  AppLifecycleListener? _lifecycle;

  @override
  DateTime build() {
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() => _lifecycle?.dispose());
    return _today();
  }

  void _refresh() => state = _today();

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
