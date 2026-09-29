import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/clock.dart';

final predictionDayProvider = NotifierProvider<PredictionDayNotifier, DateTime>(
  PredictionDayNotifier.new,
);

class PredictionDayNotifier extends Notifier<DateTime> {
  AppLifecycleListener? _lifecycle;
  late Clock _clock;

  @override
  DateTime build() {
    _clock = ref.watch(clockProvider);
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() => _lifecycle?.dispose());
    return _today();
  }

  void _refresh() => state = _today();

  DateTime _today() {
    final now = _clock.now();
    return DateTime(now.year, now.month, now.day);
  }
}
