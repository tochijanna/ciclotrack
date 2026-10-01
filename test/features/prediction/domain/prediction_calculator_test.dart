import 'package:flutter_test/flutter_test.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/prediction/domain/woman_prediction.dart';

void main() {
  final calc = PredictionCalculator();

  group('PredictionCalculator - sinDatos', () {
    test('returns sinDatos when no periods', () {
      final pred = calc.calculate(periodLogs: []);
      expect(pred.estadoRiesgo, EstadoRiesgo.sinDatos);
      expect(pred.cicloActual, isNull);
      expect(pred.pronostico, isEmpty);
      expect(pred.usaEstimacionPorDefecto, isTrue);
    });
  });

  group('PredictionCalculator - 1 periodo (defaults)', () {
    test('uses default cycle with flag', () {
      final pred = calc.calculate(
        periodLogs: [PeriodLogInput(startDate: DateTime(2026, 9, 1))],
        today: DateTime(2026, 9, 20), // day 20 → outside fertile window
      );
      expect(pred.estadoRiesgo, EstadoRiesgo.fueraDeVentana);
      expect(pred.usaEstimacionPorDefecto, isTrue);
      expect(pred.ciclosReales, 0);
      expect(pred.mediaCiclo, 28.0);
      expect(pred.cicloActual, 20);
    });
  });

  group('PredictionCalculator - fechas ancladas', () {
    test('computes concrete dates from cycle data', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 8, 5),
          ),
          PeriodLogInput(
            startDate: DateTime(2026, 8, 29),
            endDate: DateTime(2026, 9, 2),
          ),
        ],
        today: DateTime(2026, 9, 5),
      );
      expect(pred.usaEstimacionPorDefecto, isFalse);
      expect(pred.ciclosReales, 1);
      expect(pred.mediaCiclo, 28.0);
      // Last period start = 29 Aug; ovulation ≈ day14 = 11 Sep
      expect(pred.ovulacionEstimada, DateTime(2026, 9, 11));
      // Fertile window: day9-16 → 6 Sep – 13 Sep
      expect(pred.ventanaFertilInicio, DateTime(2026, 9, 6));
      expect(pred.ventanaFertilFin, DateTime(2026, 9, 13));
      // Next period: 29 Aug + 28 = 26 Sep
      expect(pred.periodoPrevisto, DateTime(2026, 9, 26));
    });

    test('uses average period duration when available', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 8, 7), // 7 days
          ),
          PeriodLogInput(
            startDate: DateTime(2026, 8, 29),
            endDate: DateTime(2026, 9, 3), // 6 days
          ),
        ],
        today: DateTime(2026, 9, 1),
      );
      // Average period duration = (7+6)/2 = 6.5 → 7
      expect(pred.duracionPeriodoEstimada, 7);
    });
  });

  group('PredictionCalculator - estadoRiesgo', () {
    test('periodoEnCurso when today is within period', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 8, 31), // day 3
      );
      expect(pred.estadoRiesgo, EstadoRiesgo.periodoEnCurso);
    });

    test('diaDeRiesgo when today is in fertile window', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 10), // day 13 → in window 9-16
      );
      expect(pred.estadoRiesgo, EstadoRiesgo.diaDeRiesgo);
    });

    test('posibleRetraso when today >= expected period', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 27), // day 30 > 28
      );
      expect(pred.estadoRiesgo, EstadoRiesgo.posibleRetraso);
    });
  });

  group('PredictionCalculator - faseHoy and humorHoy', () {
    test('menstruacion on day 2', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 8, 30), // day 2
      );
      expect(pred.faseHoy, CyclePhase.menstruacion);
      expect(pred.humorHoy, 'Bajo / cansancio');
    });

    test('ovulacion on estimated ovulation day', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 11), // day 14 → ovulation
      );
      expect(pred.faseHoy, CyclePhase.ovulacion);
      expect(pred.humorHoy, 'Muy bueno');
    });

    test('luteaTardia in PMS window', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 23), // day 26 → PMS (25-28)
      );
      expect(pred.faseHoy, CyclePhase.luteaTardia);
      expect(pred.humorHoy, 'Irritable / mal humor');
    });

    test('retraso after expected period', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 27), // day 30 > 28
      );
      expect(pred.faseHoy, CyclePhase.retraso);
      expect(pred.humorHoy, 'Imprevisible');
    });
  });

  group('PredictionCalculator - pronostico', () {
    test('forecast covers today to expected period', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 5),
      );
      expect(pred.pronostico, isNotEmpty);
      // First range starts today
      expect(pred.pronostico.first.inicio, DateTime(2026, 9, 5));
      // Last range ends day before expected period (25 Sep)
      expect(pred.pronostico.last.fin, DateTime(2026, 9, 25));
    });

    test('forecast has no gaps', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 5),
      );
      for (var i = 1; i < pred.pronostico.length; i++) {
        final prev = pred.pronostico[i - 1];
        final curr = pred.pronostico[i];
        final prevEnd = DateTime(
          prev.fin.year,
          prev.fin.month,
          prev.fin.day + 1,
        );
        expect(
          curr.inicio,
          prevEnd,
          reason: 'No gap between ranges at index ${i - 1}',
        );
      }
    });

    test('forecast includes ovulacion with cachonda label', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 5),
      );
      final ovul = pred.pronostico.where((r) => r.fase == CyclePhase.ovulacion);
      expect(ovul, isNotEmpty);
      expect(ovul.first.libido, 'Cachonda (pico)');
    });

    test('forecast includes luteaTardia with irritable label', () {
      final pred = calc.calculate(
        periodLogs: [
          PeriodLogInput(startDate: DateTime(2026, 8, 1)),
          PeriodLogInput(startDate: DateTime(2026, 8, 29)),
        ],
        today: DateTime(2026, 9, 5),
      );
      final pms = pred.pronostico.where(
        (r) => r.fase == CyclePhase.luteaTardia,
      );
      expect(pms, isNotEmpty);
      expect(pms.first.humor, 'Irritable / mal humor');
    });

    test('empty forecast when sinDatos', () {
      final pred = calc.calculate(periodLogs: []);
      expect(pred.pronostico, isEmpty);
    });
  });
}
