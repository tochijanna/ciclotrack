import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_timeline.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';

void main() {
  final horizonteLejano = DateTime(2028, 1, 1);

  CycleTimeline timeline(List<PeriodLogInput> logs, {DateTime? horizonte}) =>
      CycleTimeline.from(logs: logs, horizonte: horizonte ?? horizonteLejano);

  /// Periodo de 5 días que empieza en [year]-[month]-[day].
  PeriodLogInput periodo(int year, int month, int day, {int? duracionDias}) =>
      PeriodLogInput(
        startDate: DateTime(year, month, day),
        endDate: duracionDias == null
            ? null
            : DateTime(year, month, day + duracionDias - 1),
      );

  group('sin registros', () {
    test('no proyecta ciclos y no responde por fecha', () {
      final t = timeline(const []);

      expect(t.spans, isEmpty);
      expect(t.spanFor(DateTime(2026, 9, 1)), isNull);
      expect(t.phaseOn(DateTime(2026, 9, 1)), isNull);
      expect(t.isPeriodOn(DateTime(2026, 9, 1)), isFalse);
      expect(t.isFertileOn(DateTime(2026, 9, 1)), isFalse);
      expect(t.isOvulationOn(DateTime(2026, 9, 1)), isFalse);
      expect(t.isEstimatedOn(DateTime(2026, 9, 1)), isFalse);
      expect(t.nextFertileStart(DateTime(2026, 9, 1)), isNull);
    });
  });

  group('un periodo con endDate explícito', () {
    final t = timeline([periodo(2026, 9, 1, duracionDias: 5)]);

    test('las fechas del ciclo siguen los defaults 9-16 / día 14', () {
      final span = t.spans.first;
      expect(span.start, DateTime(2026, 9, 1));
      expect(span.periodEnd, DateTime(2026, 9, 5));
      expect(span.fertileStart, DateTime(2026, 9, 9));
      expect(span.fertileEnd, DateTime(2026, 9, 16));
      expect(span.ovulation, DateTime(2026, 9, 14));
      expect(span.esReal, isTrue);
      expect(span.periodoEstimado, isFalse);
    });

    test('responde la fase de cada día del ciclo', () {
      CyclePhase? fase(int day) => t.phaseOn(DateTime(2026, 9, day));

      expect(fase(1), CyclePhase.menstruacion);
      expect(fase(5), CyclePhase.menstruacion);
      expect(fase(6), CyclePhase.follicular);
      expect(fase(8), CyclePhase.follicular);
      expect(fase(9), CyclePhase.ventanaFertil);
      expect(fase(14), CyclePhase.ovulacion);
      expect(fase(16), CyclePhase.ventanaFertil);
      expect(fase(17), CyclePhase.lutea);
      expect(fase(24), CyclePhase.luteaTardia);
    });

    test('acota la ventana fértil por sus fronteras', () {
      expect(t.isFertileOn(DateTime(2026, 9, 8)), isFalse);
      expect(t.isFertileOn(DateTime(2026, 9, 9)), isTrue);
      expect(t.isFertileOn(DateTime(2026, 9, 16)), isTrue);
      expect(t.isFertileOn(DateTime(2026, 9, 17)), isFalse);
      expect(t.isOvulationOn(DateTime(2026, 9, 13)), isFalse);
      expect(t.isOvulationOn(DateTime(2026, 9, 14)), isTrue);
    });

    test('marca la menstruación solo hasta el fin registrado', () {
      expect(t.isPeriodOn(DateTime(2026, 9, 5)), isTrue);
      expect(t.isPeriodOn(DateTime(2026, 9, 6)), isFalse);
    });

    test('las ventanas anteriores al primer inicio no existen', () {
      expect(t.spanFor(DateTime(2026, 8, 31)), isNull);
      expect(t.phaseOn(DateTime(2026, 8, 31)), isNull);
      expect(t.isFertileOn(DateTime(2026, 8, 31)), isFalse);
    });
  });

  group('proyección de ciclos futuros', () {
    final t = timeline([periodo(2026, 9, 1, duracionDias: 5)]);

    test('proyecta un ciclo cada media de 28 días', () {
      expect(t.spans.length, greaterThan(1));
      expect(t.spans[1].start, DateTime(2026, 9, 29));
      expect(t.spans[1].esReal, isFalse);
      expect(t.spans[1].periodoEstimado, isTrue);
      expect(t.spans[2].start, DateTime(2026, 10, 27));
    });

    test('el ciclo proyectado se comporta como el real', () {
      expect(t.phaseOn(DateTime(2026, 9, 29)), CyclePhase.menstruacion);
      expect(t.phaseOn(DateTime(2026, 10, 12)), CyclePhase.ovulacion);
      expect(t.isPeriodOn(DateTime(2026, 10, 3)), isTrue);
      expect(t.isFertileOn(DateTime(2026, 10, 7)), isTrue);
      expect(t.isEstimatedOn(DateTime(2026, 10, 7)), isTrue);
    });

    test('lo registrado no se marca como estimado', () {
      expect(t.isEstimatedOn(DateTime(2026, 9, 2)), isFalse);
      expect(t.isEstimatedOn(DateTime(2026, 9, 12)), isFalse);
    });

    test('más allá del horizonte no hay cobertura', () {
      final acotada = timeline([
        periodo(2026, 9, 1, duracionDias: 5),
      ], horizonte: DateTime(2026, 12, 31));
      expect(acotada.spans.last.start, DateTime(2026, 12, 22));
      expect(acotada.spanFor(DateTime(2027, 1, 15)), isNotNull);
      expect(acotada.spanFor(DateTime(2027, 1, 19)), isNull);
      expect(acotada.phaseOn(DateTime(2027, 1, 19)), isNull);
      expect(acotada.isFertileOn(DateTime(2027, 1, 19)), isFalse);
    });
  });

  group('varios periodos', () {
    final t = timeline([
      periodo(2026, 1, 1),
      periodo(2026, 1, 25),
      periodo(2026, 2, 26),
    ]);

    test('cada inicio registrado abre su propio ciclo', () {
      expect(t.spans.take(3).map((s) => s.start), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 25),
        DateTime(2026, 2, 26),
      ]);
      expect(t.spans.take(3).every((s) => s.esReal), isTrue);
    });

    test('cada ciclo usa la ventana fértil calculada', () {
      expect(t.spans[1].fertileStart, DateTime(2026, 2, 2));
      expect(t.spans[1].fertileEnd, DateTime(2026, 2, 9));
      expect(t.isFertileOn(DateTime(2026, 2, 1)), isFalse);
      expect(t.isFertileOn(DateTime(2026, 2, 2)), isTrue);
      expect(t.isFertileOn(DateTime(2026, 2, 9)), isTrue);
      expect(t.isFertileOn(DateTime(2026, 2, 10)), isFalse);
    });

    test('nextFertileStart salta las ventanas ya cerradas', () {
      expect(t.nextFertileStart(DateTime(2026, 1, 1)), DateTime(2026, 1, 9));
      expect(t.nextFertileStart(DateTime(2026, 1, 20)), DateTime(2026, 2, 2));
      expect(t.nextFertileStart(DateTime(2026, 2, 10)), DateTime(2026, 3, 6));
    });

    test('estima la menstruación con la media cuando falta el endDate', () {
      final t = timeline([
        periodo(2026, 1, 1, duracionDias: 4),
        periodo(2026, 1, 29),
      ]);

      expect(t.spans[1].periodEnd, DateTime(2026, 2, 1));
      expect(t.spans[1].periodoEstimado, isTrue);
      expect(t.isPeriodOn(DateTime(2026, 2, 1)), isTrue);
      expect(t.isPeriodOn(DateTime(2026, 2, 2)), isFalse);
      expect(t.isEstimatedOn(DateTime(2026, 2, 1)), isTrue);
      expect(t.isEstimatedOn(DateTime(2026, 2, 10)), isFalse);
    });

    test('un endDate largo alarga la menstruación y la fase', () {
      final largo = timeline([periodo(2026, 9, 1, duracionDias: 8)]);
      expect(largo.phaseOn(DateTime(2026, 9, 8)), CyclePhase.menstruacion);
      expect(largo.isPeriodOn(DateTime(2026, 9, 8)), isTrue);
      expect(largo.isPeriodOn(DateTime(2026, 9, 9)), isFalse);
      expect(largo.phaseOn(DateTime(2026, 9, 9)), CyclePhase.ventanaFertil);
    });
  });

  group('entradas degeneradas', () {
    test('ignora inicios duplicados en lugar de crear ciclos de cero días', () {
      final t = timeline([
        periodo(2026, 1, 1, duracionDias: 5),
        periodo(2026, 1, 1, duracionDias: 5),
      ]);

      expect(t.spans.where((s) => s.esReal).length, 1);
      expect(t.spans[1].start, DateTime(2026, 1, 29));
    });

    test('ordena los registros desordenados', () {
      final t = timeline([periodo(2026, 2, 26), periodo(2026, 1, 1)]);

      expect(t.spans.first.start, DateTime(2026, 1, 1));
      expect(t.spans[1].start, DateTime(2026, 2, 26));
    });

    test('normaliza las fechas con hora a día calendario', () {
      final t = timeline([
        PeriodLogInput(startDate: DateTime(2026, 9, 1, 23, 59)),
        PeriodLogInput(startDate: DateTime(2026, 9, 29, 0, 1)),
      ]);

      expect(t.spans.first.start, DateTime(2026, 9, 1));
      expect(t.spans[1].start, DateTime(2026, 9, 29));
      expect(t.phaseOn(DateTime(2026, 9, 1, 12)), CyclePhase.menstruacion);
    });
  });
}
