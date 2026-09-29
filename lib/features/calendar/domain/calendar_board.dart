import '../../encounters/domain/encounter_event.dart';
import '../../prediction/domain/cycle_phase.dart';
import '../../prediction/domain/cycle_timeline.dart';
import '../../tracking/domain/tracking_event.dart';
import 'day_mark.dart';

/// Proyección de un perfil para las vistas de calendario.
///
/// [WomanProfile] vive en la capa de datos, por lo que el dominio del
/// calendario solo conoce estos campos primitivos.
class CalendarWoman {
  const CalendarWoman({
    required this.id,
    required this.name,
    required this.initials,
    required this.emoji,
    required this.color,
  });

  final int id;
  final String name;
  final String initials;
  final String emoji;
  final int color;
}

/// Una mujer con su línea temporal de ciclos y sus registros de tracking.
class WomanCalendar {
  const WomanCalendar({
    required this.woman,
    required this.timeline,
    required this.eventos,
  });

  final CalendarWoman woman;
  final CycleTimeline timeline;

  /// Ovulaciones y síntomas registrados; los periodos ya se representan a
  /// través de la línea temporal.
  final List<TrackingEvent> eventos;
}

/// Estado consolidado que consumen las cuatro vistas.
class CalendarBoard {
  const CalendarBoard({required this.women, required this.encuentros});

  final List<WomanCalendar> women;
  final List<EncounterWithWomen> encuentros;
}

/// Detalle de un día concreto para una mujer.
class DayDetail {
  const DayDetail({
    required this.woman,
    required this.fase,
    required this.fertil,
    required this.esEstimado,
    required this.eventos,
    required this.encuentros,
  });

  final CalendarWoman woman;

  /// `null` cuando la línea temporal no cubre la fecha (sin datos).
  final CyclePhase? fase;
  final bool fertil;
  final bool esEstimado;
  final List<TrackingEvent> eventos;
  final List<EncounterWithWomen> encuentros;
}

/// Ventana fértil que intersecta la semana consultada.
class FertileWeekEntry {
  const FertileWeekEntry({
    required this.woman,
    required this.ventanaInicio,
    required this.ventanaFin,
    required this.ovulacion,
    required this.esEstimado,
  });

  final CalendarWoman woman;
  final DateTime ventanaInicio;
  final DateTime ventanaFin;
  final DateTime ovulacion;
  final bool esEstimado;
}

/// Marcas por día para el rango [desde]..[hasta], ambos inclusive.
Map<DateTime, List<DayMark>> marksByDay(
  CalendarBoard board, {
  required DateTime desde,
  required DateTime hasta,
}) {
  final inicio = _calendarDate(desde);
  final fin = _calendarDate(hasta);
  final marks = <DateTime, List<DayMark>>{};
  final eventosPorMujer = _eventosPorDia(board);

  for (final wc in board.women) {
    final porDia = eventosPorMujer[wc.woman.id];
    for (var day = inicio; !day.isAfter(fin); day = _addDays(day, 1)) {
      final estimado = wc.timeline.isEstimatedOn(day);
      for (final kind in _kindsDe(wc.timeline, porDia?[day], day)) {
        (marks[day] ??= <DayMark>[]).add(
          DayMark(
            womanId: wc.woman.id,
            color: wc.woman.color,
            kind: kind,
            esEstimado: estimado,
          ),
        );
      }
    }
  }

  final ids = {for (final wc in board.women) wc.woman.id};
  for (final encuentro in board.encuentros) {
    final day = _calendarDate(encuentro.encounterTime);
    if (day.isBefore(inicio) || day.isAfter(fin)) continue;
    for (final participante in encuentro.participants) {
      if (!ids.contains(participante.womanId)) continue;
      (marks[day] ??= <DayMark>[]).add(
        DayMark(
          womanId: participante.womanId,
          color: participante.womanColor,
          kind: DayMarkKind.encuentro,
        ),
      );
    }
  }

  return marks;
}

/// Detalle de [day] para cada mujer del tablero, en el orden de los perfiles.
List<DayDetail> detailsFor(CalendarBoard board, DateTime day) {
  final fecha = _calendarDate(day);
  return [
    for (final wc in board.women)
      DayDetail(
        woman: wc.woman,
        fase: wc.timeline.phaseOn(fecha),
        fertil: wc.timeline.isFertileOn(fecha),
        esEstimado: wc.timeline.isEstimatedOn(fecha),
        eventos: [
          for (final evento in wc.eventos)
            if (_calendarDate(evento.date) == fecha) evento,
        ],
        encuentros: [
          for (final encuentro in board.encuentros)
            if (_esDelDia(encuentro, wc.woman.id, fecha)) encuentro,
        ],
      ),
  ];
}

/// Lunes de la semana que contiene [day].
DateTime startOfWeek(DateTime day) {
  final fecha = _calendarDate(day);
  return _addDays(fecha, -(fecha.weekday - DateTime.monday));
}

/// Mujeres cuya ventana fértil intersecta la semana que empieza en [weekStart].
List<FertileWeekEntry> fertileInWeek(CalendarBoard board, DateTime weekStart) {
  final inicio = _calendarDate(weekStart);
  final fin = _addDays(inicio, 6);
  final entradas = <FertileWeekEntry>[];

  for (final wc in board.women) {
    for (final span in wc.timeline.spans) {
      if (span.fertileEnd.isBefore(inicio) || span.fertileStart.isAfter(fin)) {
        continue;
      }
      entradas.add(
        FertileWeekEntry(
          woman: wc.woman,
          ventanaInicio: span.fertileStart,
          ventanaFin: span.fertileEnd,
          ovulacion: span.ovulation,
          esEstimado: !span.esReal,
        ),
      );
    }
  }

  entradas.sort((a, b) => a.ventanaInicio.compareTo(b.ventanaInicio));
  return entradas;
}

List<DayMarkKind> _kindsDe(
  CycleTimeline timeline,
  List<TrackingEvent>? eventos,
  DateTime day,
) {
  final kinds = <DayMarkKind>[];
  if (timeline.isPeriodOn(day)) kinds.add(DayMarkKind.menstruacion);
  if (timeline.isOvulationOn(day)) {
    kinds.add(DayMarkKind.ovulacion);
  } else if (timeline.isFertileOn(day)) {
    kinds.add(DayMarkKind.ventanaFertil);
  }
  for (final evento in eventos ?? const <TrackingEvent>[]) {
    if (evento.type == TrackingEventType.ovulation) {
      kinds.add(DayMarkKind.ovulacionRegistrada);
    }
    if (evento.type == TrackingEventType.symptom) {
      kinds.add(DayMarkKind.sintoma);
    }
  }
  return kinds;
}

Map<int, Map<DateTime, List<TrackingEvent>>> _eventosPorDia(
  CalendarBoard board,
) {
  final porMujer = <int, Map<DateTime, List<TrackingEvent>>>{};
  for (final wc in board.women) {
    final porDia = <DateTime, List<TrackingEvent>>{};
    for (final evento in wc.eventos) {
      (porDia[_calendarDate(evento.date)] ??= <TrackingEvent>[]).add(evento);
    }
    porMujer[wc.woman.id] = porDia;
  }
  return porMujer;
}

bool _esDelDia(EncounterWithWomen encuentro, int womanId, DateTime fecha) =>
    _calendarDate(encuentro.encounterTime) == fecha &&
    encuentro.participants.any((p) => p.womanId == womanId);

DateTime _calendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);
