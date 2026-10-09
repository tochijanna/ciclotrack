import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/privacy/discreet_notices.dart';
import '../../../alerts/presentation/providers/alerts_providers.dart';
import 'reminder_providers.dart';

/// Ajuste de avisos discretos: notificaciones con texto genérico (PRIV-04).
class DiscreetNoticesController extends Notifier<bool> {
  @override
  bool build() {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    Future.microtask(() async {
      final value = await readDiscreetNotices();
      if (!disposed) state = value;
    });
    return true;
  }

  /// Persiste el ajuste y reprograma lo pendiente con el texto nuevo
  /// (PRIV-05).
  Future<void> setEnabled(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(discreetNoticesPrefKey, value);
    } catch (_) {
      // Sin persistencia los avisos siguen con el valor guardado.
    }
    await ref.read(alertsCoordinatorProvider).refreshNow();
    await ref.read(reminderCoordinatorProvider).refreshNow();
  }
}

final discreetNoticesProvider =
    NotifierProvider<DiscreetNoticesController, bool>(
      DiscreetNoticesController.new,
    );
