import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../prediction/presentation/providers/prediction_day_provider.dart';
import '../../domain/report_builder.dart';
import '../../domain/report_models.dart';

/// Mujer seleccionada en la pantalla de reportes; `null` = todas.
class SelectedWomanNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? womanId) => state = womanId;
}

final selectedWomanProvider = NotifierProvider<SelectedWomanNotifier, int?>(
  SelectedWomanNotifier.new,
);

/// Informe derivado del tablero consolidado y del día actual.
///
/// No tiene estado propio: todo se recalcula cuando cambia el tablero (una
/// emisión por cambio de datos) o el día.
final reportsBoardProvider = Provider<AsyncValue<ReportsBoard>>((ref) {
  final today = ref.watch(predictionDayProvider);
  return ref
      .watch(calendarBoardProvider)
      .whenData((board) => buildReports(board, today: today));
});
