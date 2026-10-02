class CyclePrediction {
  const CyclePrediction({
    required this.minCycle,
    required this.maxCycle,
    required this.averageCycle,
    required this.ovulationRangeStart,
    required this.ovulationRangeEnd,
    required this.estimatedOvulationDay,
    required this.fertilityWindowStart,
    required this.fertilityWindowEnd,
  });

  final int minCycle;
  final int maxCycle;
  final double averageCycle;
  final int ovulationRangeStart;
  final int ovulationRangeEnd;
  final int estimatedOvulationDay;
  final int fertilityWindowStart;
  final int fertilityWindowEnd;
}

final class PredictionEngine {
  static const int defaultCycleMinLength = 24;
  static const int defaultCycleMaxLength = 32;
  static const int defaultCycleLength = 28;

  /// Devuelve la duración entre inicios de periodo consecutivos (en días).
  List<int> cycleLengthsFrom(List<DateTime> periodStarts) {
    final dates =
        periodStarts
            .map((date) => DateTime(date.year, date.month, date.day))
            .toList()
          ..sort();
    if (dates.length < 2) {
      return const [];
    }
    return [
      for (var i = 1; i < dates.length; i++)
        if (dates[i] != dates[i - 1]) _daysBetween(dates[i - 1], dates[i]),
    ];
  }

  CyclePrediction predict({List<int> cycleLengths = const []}) {
    // Descarta longitudes inválidas (<= 0) para no contaminar min/max/media.
    final valid = cycleLengths
        .where((length) => length > 0)
        .toList(growable: false);
    final min = valid.isEmpty
        ? defaultCycleMinLength
        : (valid.reduce((a, b) => a < b ? a : b));
    final max = valid.isEmpty
        ? defaultCycleMaxLength
        : (valid.reduce((a, b) => a > b ? a : b));
    final average = valid.isEmpty
        ? defaultCycleLength.toDouble()
        : valid.reduce((a, b) => a + b) / valid.length;

    final rangeStart = valid.isEmpty
        ? 11
        : _clamp(11 - (28 - min), min: 1, max: max);
    final rangeEnd = valid.isEmpty
        ? 17
        : _clamp(17 + (max - 28), min: 1, max: max);
    final estimated = _clamp((average - 14).round(), min: 1, max: max);
    final fertilityStart = _clamp(estimated - 5, min: 1, max: max);
    final fertilityEnd = _clamp(estimated + 2, min: estimated, max: max);

    return CyclePrediction(
      minCycle: min,
      maxCycle: max,
      averageCycle: average,
      ovulationRangeStart: rangeStart,
      ovulationRangeEnd: rangeEnd,
      estimatedOvulationDay: estimated,
      fertilityWindowStart: fertilityStart,
      fertilityWindowEnd: fertilityEnd,
    );
  }

  DateTime? predictNextPeriod(DateTime lastPeriodStart, double averageCycle) {
    final days = averageCycle.round();
    if (days <= 0) {
      return null;
    }
    return DateTime(
      lastPeriodStart.year,
      lastPeriodStart.month,
      lastPeriodStart.day + days,
    );
  }

  int _clamp(int value, {required int min, required int max}) =>
      value < min ? min : (value > max ? max : value);
}

/// Días de calendario entre dos fechas, insensible a cambios de hora (DST):
/// se normaliza a UTC antes de restar para que 28 días reales midan 28.
int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
