import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/core/time/clock.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/prediction/domain/woman_prediction.dart';
import 'package:ciclotrack/features/prediction/presentation/providers/prediction_day_provider.dart';
import 'package:ciclotrack/features/prediction/presentation/providers/prediction_providers.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

/// Reloj mutable controlable desde los tests.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  void advanceDays(int days) =>
      _now = DateTime(_now.year, _now.month, _now.day + days);

  @override
  DateTime now() => _now;
}

/// Simula volver a la app: llevar el ciclo de vida a `inactive` y luego a
/// `resumed` es la transición que dispara `AppLifecycleListener.onResume`.
void _resumeApp() {
  final binding = WidgetsBinding.instance;
  binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

void main() {
  // `AppLifecycleListener` (creado al construir el notifier) requiere un
  // `WidgetsBinding` disponible aunque estos tests no monten widgets.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('predictionDayProvider', () {
    test('estado inicial: medianoche local del reloj', () {
      final fake = FakeClock(DateTime(2026, 9, 15, 13, 45, 30));
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(container.read(predictionDayProvider), DateTime(2026, 9, 15));
    });

    test('cambio de día: al reanudar la app el estado avanza al día nuevo', () {
      final fake = FakeClock(DateTime(2026, 9, 15, 23, 30));
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(container.read(predictionDayProvider), DateTime(2026, 9, 15));

      fake.advanceDays(1);
      _resumeApp();

      expect(container.read(predictionDayProvider), DateTime(2026, 9, 16));
    });
  });

  group('predictionDayProvider + womanPredictionProvider', () {
    test(
      'cruzar el límite de la ventana fértil recalcula la predicción',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        final womanId = await WomenRepository(
          WomenDao(db),
        ).create(const WomanDraft(name: 'María', initials: 'MR'));

        // Periodo 2026-09-01 → 2026-09-05. Con la estimación por defecto
        // (ciclo de 28 días) la ventana fértil arranca en el día 9 del ciclo.
        await TrackingRepository(TrackingDao(db)).createPeriod(
          womanId,
          PeriodDraft(
            startDate: DateTime(2026, 9, 1),
            endDate: DateTime(2026, 9, 5),
          ),
        );

        // Día 8 del ciclo → fuera de la ventana fértil.
        final fake = FakeClock(DateTime(2026, 9, 8));
        final container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(fake),
            appDatabaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        final emissions = <WomanPrediction?>[];
        final sub = container.listen(
          womanPredictionProvider(womanId),
          (_, next) => emissions.add(next.value),
          fireImmediately: true,
        );
        addTearDown(sub.close);

        await pumpEventQueue();

        expect(emissions.last, isNotNull);
        expect(emissions.last!.estadoRiesgo, EstadoRiesgo.fueraDeVentana);
        expect(emissions.last!.faseHoy, CyclePhase.follicular);

        // Día 9 del ciclo → primer día de la ventana fértil.
        fake.advanceDays(1);
        _resumeApp();
        await pumpEventQueue();

        expect(emissions.last, isNotNull);
        expect(emissions.last!.estadoRiesgo, EstadoRiesgo.diaDeRiesgo);
        expect(emissions.last!.faseHoy, CyclePhase.ventanaFertil);
      },
    );
  });
}
