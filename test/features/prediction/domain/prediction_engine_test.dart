import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/prediction/domain/prediction_engine.dart';

void main() {
  final engine = PredictionEngine();

  group('cycleLengthsFrom', () {
    test('returns empty when less than two dates', () {
      expect(engine.cycleLengthsFrom([DateTime(2026, 1, 1)]), isEmpty);
      expect(engine.cycleLengthsFrom([]), isEmpty);
    });

    test('computes differences between consecutive starts', () {
      final lengths = engine.cycleLengthsFrom([
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 29),
        DateTime(2026, 2, 26),
      ]);
      expect(lengths, [28, 28]);
    });

    test('sorts unsorted input before computing', () {
      final lengths = engine.cycleLengthsFrom([
        DateTime(2026, 2, 26),
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 29),
      ]);
      expect(lengths, [28, 28]);
    });
  });

  group('predict', () {
    test('uses defaults when no data is available', () {
      final p = engine.predict();
      expect(p.minCycle, 24);
      expect(p.maxCycle, 32);
      expect(p.averageCycle, 28);
      expect(p.estimatedOvulationDay, 14);
      expect(p.fertilityWindowStart, 9);
      expect(p.fertilityWindowEnd, 16);
    });

    test('computes min, max and average from real cycles', () {
      final p = engine.predict(cycleLengths: [26, 30, 28]);
      expect(p.minCycle, 26);
      expect(p.maxCycle, 30);
      expect(p.averageCycle, 28);
    });

    test('ovulation range follows the spec formula and stays in bounds', () {
      final p = engine.predict(cycleLengths: [24, 32]);
      expect(p.ovulationRangeStart, 1);
      expect(p.ovulationRangeEnd, 32);
    });

    test('ovulation range for a normal cycle', () {
      final p = engine.predict(cycleLengths: [28, 28]);
      expect(p.ovulationRangeStart, 1);
      expect(p.ovulationRangeEnd, 28);
    });

    test('fertilidad window is estimatedOvulation -5 / +2', () {
      final p = engine.predict(cycleLengths: [30, 30, 30]);
      expect(p.estimatedOvulationDay, 16);
      expect(p.fertilityWindowStart, 11);
      expect(p.fertilityWindowEnd, 18);
    });

    test('clamps fertility window to cycle boundary', () {
      final p = engine.predict(cycleLengths: [20, 20, 20]);
      expect(p.fertilityWindowStart, 1);
      expect(p.fertilityWindowEnd, 8);
    });
  });

  group('predictNextPeriod', () {
    test('adds average cycle to the last period start', () {
      final next = engine.predictNextPeriod(DateTime(2026, 9, 10), 28);
      expect(next, DateTime(2026, 10, 8));
    });

    test('returns null for non-positive average', () {
      expect(engine.predictNextPeriod(DateTime(2026, 9, 10), 0), isNull);
    });
  });
}
