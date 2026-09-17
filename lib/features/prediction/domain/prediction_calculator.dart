import 'cycle_phase.dart';
import 'mood_forecast.dart';
import 'prediction_engine.dart';
import 'woman_prediction.dart';

/// Conversión pura de datos de periodo en [WomanPrediction] completa.
class PredictionCalculator {
  PredictionCalculator({PredictionEngine? engine})
    : _engine = engine ?? PredictionEngine();

  final PredictionEngine _engine;

  static const int defaultPeriodDuration = 5;

  /// Calcula la predicción a partir de los registros de periodo.
  ///
  /// [periodLogs] debe estar ordenado por startDate ascendente.
  /// [today] es inyectable para tests (por defecto DateTime.now()).
  WomanPrediction calculate({
    required List<PeriodLogInput> periodLogs,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();

    if (periodLogs.isEmpty) {
      return WomanPrediction(
        estadoRiesgo: EstadoRiesgo.sinDatos,
        faseHoy: CyclePhase.follicular,
        humorHoy: '—',
        pronostico: const [],
        ovulacionEstimada: null,
        rangoOvulacionInicio: null,
        rangoOvulacionFin: null,
        ventanaFertilInicio: null,
        ventanaFertilFin: null,
        periodoPrevisto: null,
        minCiclo: PredictionEngine.defaultCycleMinLength,
        maxCiclo: PredictionEngine.defaultCycleMaxLength,
        mediaCiclo: PredictionEngine.defaultCycleLength.toDouble(),
        ciclosReales: 0,
        usaEstimacionPorDefecto: true,
        cicloActual: null,
      );
    }

    // Duración media de la menstruación (solo periodos con endDate).
    final durations = periodLogs
        .where((p) => p.endDate != null)
        .map(
          (p) =>
              _calendarDate(
                p.endDate!,
              ).difference(_calendarDate(p.startDate)).inDays +
              1,
        )
        .toList();
    final periodDuration = durations.isEmpty
        ? defaultPeriodDuration
        : (durations.reduce((a, b) => a + b) / durations.length).round();

    // Motor de predicción.
    final startDates = periodLogs
        .map((p) => _calendarDate(p.startDate))
        .toList();
    final cycleLengths = _engine.cycleLengthsFrom(startDates);
    final prediction = _engine.predict(cycleLengths: cycleLengths);
    final lastStart = _calendarDate(periodLogs.last.startDate);
    final avgCycle = prediction.averageCycle;
    final expectedPeriod = _engine.predictNextPeriod(lastStart, avgCycle);
    final isDefault = cycleLengths.isEmpty;

    // Día actual del ciclo.
    final cycleDay = now.difference(lastStart).inDays + 1;

    // Fase y humor de hoy.
    final phase = phaseForCycleDay(
      cycleDay,
      prediction,
      periodDuration,
      avgCycle,
    );
    final mood = moodByPhase[phase]!;

    // Estado de riesgo.
    final estado = _estadoRiesgo(
      cycleDay,
      prediction,
      expectedPeriod,
      periodDuration,
      now,
      lastStart,
    );

    // Fechas concretas.
    DateTime? addDays(DateTime base, int days) =>
        DateTime(base.year, base.month, base.day + days);

    final ovulEstimada = addDays(
      lastStart,
      prediction.estimatedOvulationDay - 1,
    );
    final rangoOvIni = addDays(lastStart, prediction.ovulationRangeStart - 1);
    final rangoOvFin = addDays(lastStart, prediction.ovulationRangeEnd - 1);
    final ventFertIni = addDays(lastStart, prediction.fertilityWindowStart - 1);
    final ventFertFin = addDays(lastStart, prediction.fertilityWindowEnd - 1);

    // Pronóstico desde hoy hasta el periodo previsto.
    final pronostico = _buildForecast(
      now: now,
      lastStart: lastStart,
      prediction: prediction,
      periodDuration: periodDuration,
      averageCycle: avgCycle,
      expectedPeriod: expectedPeriod,
    );

    return WomanPrediction(
      estadoRiesgo: estado,
      faseHoy: phase,
      humorHoy: mood.humor,
      pronostico: pronostico,
      ovulacionEstimada: ovulEstimada,
      rangoOvulacionInicio: rangoOvIni,
      rangoOvulacionFin: rangoOvFin,
      ventanaFertilInicio: ventFertIni,
      ventanaFertilFin: ventFertFin,
      periodoPrevisto: expectedPeriod,
      minCiclo: prediction.minCycle,
      maxCiclo: prediction.maxCycle,
      mediaCiclo: avgCycle,
      ciclosReales: cycleLengths.length,
      usaEstimacionPorDefecto: isDefault,
      duracionPeriodoEstimada: periodDuration,
      cicloActual: cycleDay,
    );
  }

  DateTime _calendarDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  EstadoRiesgo _estadoRiesgo(
    int cycleDay,
    CyclePrediction prediction,
    DateTime? expectedPeriod,
    int periodDuration,
    DateTime now,
    DateTime lastStart,
  ) {
    if (cycleDay <= periodDuration) return EstadoRiesgo.periodoEnCurso;
    if (expectedPeriod != null && !now.isBefore(expectedPeriod)) {
      return EstadoRiesgo.posibleRetraso;
    }
    if (cycleDay >= prediction.fertilityWindowStart &&
        cycleDay <= prediction.fertilityWindowEnd) {
      return EstadoRiesgo.diaDeRiesgo;
    }
    return EstadoRiesgo.fueraDeVentana;
  }

  List<RangoFase> _buildForecast({
    required DateTime now,
    required DateTime lastStart,
    required CyclePrediction prediction,
    required int periodDuration,
    required double averageCycle,
    required DateTime? expectedPeriod,
  }) {
    if (expectedPeriod == null) return const [];

    final ranges = <RangoFase>[];
    var dayStart = now;

    while (dayStart.isBefore(expectedPeriod)) {
      final cycleDayOfStart = dayStart.difference(lastStart).inDays + 1;
      final phase = phaseForCycleDay(
        cycleDayOfStart,
        prediction,
        periodDuration,
        averageCycle,
      );
      final mood = moodByPhase[phase]!;

      // Encontrar dónde cambia la fase.
      var dayEnd = dayStart;
      while (true) {
        final nextDay = DateTime(dayEnd.year, dayEnd.month, dayEnd.day + 1);
        if (!nextDay.isBefore(expectedPeriod)) break;
        final nextCycleDay = nextDay.difference(lastStart).inDays + 1;
        final nextPhase = phaseForCycleDay(
          nextCycleDay,
          prediction,
          periodDuration,
          averageCycle,
        );
        if (nextPhase != phase) break;
        dayEnd = nextDay;
      }

      ranges.add(
        RangoFase(
          inicio: dayStart,
          fin: dayEnd,
          fase: phase,
          humor: mood.humor,
          libido: mood.libido,
          consejo: mood.consejo,
        ),
      );

      dayStart = DateTime(dayEnd.year, dayEnd.month, dayEnd.day + 1);
    }

    return ranges;
  }
}

/// Entrada simplificada de un registro de periodo (para desacoplarse de Drift).
class PeriodLogInput {
  const PeriodLogInput({required this.startDate, this.endDate});

  final DateTime startDate;
  final DateTime? endDate;
}
