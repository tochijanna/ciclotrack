import 'cycle_phase.dart';
import 'prediction_calculator.dart';
import 'prediction_engine.dart';

/// Un ciclo de la línea temporal.
///
/// Los ciclos reales arrancan en un periodo registrado; los proyectados se
/// derivan del último inicio conocido más la media de ciclos.
class CycleSpan {
  const CycleSpan({
    required this.start,
    required this.periodEnd,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
    required this.esReal,
    required this.periodoEstimado,
  });

  /// Primer día del ciclo.
  final DateTime start;

  /// Último día de menstruación (real si el registro tiene `endDate`).
  final DateTime periodEnd;

  /// Ovulación estimada del ciclo.
  final DateTime ovulation;

  /// Primer y último día de la ventana fértil (ovulación −5 / +2).
  final DateTime fertileStart;
  final DateTime fertileEnd;

  /// `true` cuando el ciclo arranca en un periodo registrado.
  final bool esReal;

  /// `true` cuando el final del periodo es una estimación (sin `endDate`).
  final bool periodoEstimado;
}

/// Línea temporal de ciclos de una mujer, consultable por fecha arbitraria.
///
/// [WomanPrediction] solo describe el ciclo en curso a partir de "hoy"; las
/// vistas consolidadas necesitan la fase y la ventana fértil de cualquier día.
/// Los ciclos reales salen de los periodos registrados y los futuros se
/// proyectan con la media de ciclos hasta [horizonte]; más allá de esa fecha la
/// línea temporal no cubre el día y todas las consultas devuelven `null`.
class CycleTimeline {
  CycleTimeline._({
    required this.spans,
    required CyclePrediction prediction,
    required int mediaCiclo,
  }) : _prediction = prediction,
       _mediaCiclo = mediaCiclo;

  /// Construye la línea temporal a partir de los periodos registrados.
  ///
  /// [logs] no necesita venir ordenado; se normaliza a día calendario.
  /// [horizonte] limita hasta qué fecha se proyectan ciclos futuros.
  factory CycleTimeline.from({
    required List<PeriodLogInput> logs,
    required DateTime horizonte,
    PredictionEngine? engine,
  }) {
    final motor = engine ?? PredictionEngine();
    final normalizados = logs.map(_normalizar).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final unicos = <PeriodLogInput>[];
    for (final log in normalizados) {
      if (unicos.isEmpty || unicos.last.startDate != log.startDate) {
        unicos.add(log);
      }
    }

    if (unicos.isEmpty) {
      return CycleTimeline._(
        spans: const [],
        prediction: motor.predict(),
        mediaCiclo: PredictionEngine.defaultCycleLength,
      );
    }

    final duracionPeriodo = _duracionMedia(unicos);
    final prediction = motor.predict(
      cycleLengths: motor.cycleLengthsFrom([
        for (final log in unicos) log.startDate,
      ]),
    );
    final media = prediction.averageCycle.round();
    final limite = _calendarDate(horizonte);

    final spans = <CycleSpan>[
      for (final log in unicos)
        _span(
          desde: log.startDate,
          finReal: log.endDate,
          prediction: prediction,
          duracionPeriodo: duracionPeriodo,
          esReal: true,
        ),
    ];

    if (media > 0) {
      var inicio = unicos.last.startDate;
      while (true) {
        final siguiente = _addDays(inicio, media);
        if (siguiente.isAfter(limite)) break;
        spans.add(
          _span(
            desde: siguiente,
            finReal: null,
            prediction: prediction,
            duracionPeriodo: duracionPeriodo,
            esReal: false,
          ),
        );
        inicio = siguiente;
      }
    }

    return CycleTimeline._(
      spans: spans,
      prediction: prediction,
      mediaCiclo: media,
    );
  }

  /// Ciclos en orden cronológico: los reales primero y las proyecciones después.
  final List<CycleSpan> spans;

  final CyclePrediction _prediction;
  final int _mediaCiclo;

  /// Ciclo que contiene [day], o `null` si queda fuera de la línea temporal.
  CycleSpan? spanFor(DateTime day) {
    final fecha = _calendarDate(day);
    if (spans.isEmpty) return null;
    if (fecha.isAfter(_addDays(spans.last.start, _mediaCiclo - 1))) return null;

    CycleSpan? encontrado;
    for (final span in spans) {
      if (span.start.isAfter(fecha)) break;
      encontrado = span;
    }
    return encontrado;
  }

  /// Fase del ciclo en [day], o `null` cuando no hay datos para esa fecha.
  CyclePhase? phaseOn(DateTime day) {
    final span = spanFor(day);
    if (span == null) return null;
    final cycleDay = _calendarDate(day).difference(span.start).inDays + 1;
    final periodDays = span.periodEnd.difference(span.start).inDays + 1;
    return phaseForCycleDay(
      cycleDay,
      _prediction,
      periodDays,
      _prediction.averageCycle,
    );
  }

  /// `true` si [day] cae dentro de la menstruación del ciclo que lo contiene.
  bool isPeriodOn(DateTime day) {
    final span = spanFor(day);
    if (span == null) return false;
    return !_calendarDate(day).isAfter(span.periodEnd);
  }

  /// `true` si [day] cae dentro de la ventana fértil.
  bool isFertileOn(DateTime day) {
    final span = spanFor(day);
    if (span == null) return false;
    final fecha = _calendarDate(day);
    return !fecha.isBefore(span.fertileStart) &&
        !fecha.isAfter(span.fertileEnd);
  }

  /// `true` si [day] es el día de ovulación estimado.
  bool isOvulationOn(DateTime day) {
    final span = spanFor(day);
    return span != null && _calendarDate(day) == span.ovulation;
  }

  /// `true` cuando lo que se muestra en [day] es una proyección, no un registro:
  /// ciclos futuros y menstruaciones sin `endDate` explícito.
  bool isEstimatedOn(DateTime day) {
    final span = spanFor(day);
    if (span == null) return false;
    if (!span.esReal) return true;
    return span.periodoEstimado && isPeriodOn(day);
  }

  /// Inicio de la primera ventana fértil que no ha terminado antes de [from].
  DateTime? nextFertileStart(DateTime from) {
    final fecha = _calendarDate(from);
    for (final span in spans) {
      if (!span.fertileEnd.isBefore(fecha)) return span.fertileStart;
    }
    return null;
  }
}

/// Duración media de la menstruación de los periodos con `endDate`.
int _duracionMedia(List<PeriodLogInput> logs) {
  final duraciones = [
    for (final log in logs)
      if (log.endDate != null)
        log.endDate!.difference(log.startDate).inDays + 1,
  ];
  if (duraciones.isEmpty) return defaultPeriodDuration;
  return (duraciones.reduce((a, b) => a + b) / duraciones.length).round();
}

CycleSpan _span({
  required DateTime desde,
  required DateTime? finReal,
  required CyclePrediction prediction,
  required int duracionPeriodo,
  required bool esReal,
}) {
  final inicio = _calendarDate(desde);
  return CycleSpan(
    start: inicio,
    periodEnd: finReal == null
        ? _addDays(inicio, duracionPeriodo - 1)
        : _calendarDate(finReal),
    ovulation: _addDays(inicio, prediction.estimatedOvulationDay - 1),
    fertileStart: _addDays(inicio, prediction.fertilityWindowStart - 1),
    fertileEnd: _addDays(inicio, prediction.fertilityWindowEnd - 1),
    esReal: esReal,
    periodoEstimado: finReal == null,
  );
}

PeriodLogInput _normalizar(PeriodLogInput log) => PeriodLogInput(
  startDate: _calendarDate(log.startDate),
  endDate: log.endDate == null ? null : _calendarDate(log.endDate!),
);

DateTime _calendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);
