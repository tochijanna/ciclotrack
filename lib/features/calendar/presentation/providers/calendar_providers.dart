import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../encounters/presentation/providers/encounter_providers.dart';
import '../../../prediction/presentation/providers/prediction_day_provider.dart';
import '../../../profiles/presentation/providers/women_providers.dart';
import '../../../tracking/presentation/providers/tracking_providers.dart';
import '../../data/calendar_repository.dart';
import '../../domain/calendar_board.dart';

/// Reutiliza los repositorios de cada feature para no duplicar la construcción
/// de DAOs (mismo patrón que la feature `alerts`).
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(
    womenRepo: ref.watch(womenRepositoryProvider),
    trackingDao: ref.watch(trackingDaoProvider),
    encounterRepo: ref.watch(encounterRepositoryProvider),
  );
});

/// Tablero consolidado de las cuatro vistas. Se recalcula al cambiar el día.
final calendarBoardProvider = StreamProvider.autoDispose<CalendarBoard>((ref) {
  final today = ref.watch(predictionDayProvider);
  return ref.watch(calendarRepositoryProvider).watchBoard(today: today);
});
