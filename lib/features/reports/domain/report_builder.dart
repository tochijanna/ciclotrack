import '../../calendar/domain/calendar_board.dart';
import '../../encounters/domain/encounter_event.dart';
import '../../encounters/domain/encounter_options.dart';
import '../../prediction/domain/cycle_timeline.dart';
import '../../../../core/time/calendar_days.dart';
import '../../tracking/domain/tracking_event.dart';
import 'report_models.dart';

/// Construye el informe agregado a partir del tablero consolidado.
///
/// Ventanas: los ciclos y sus medias cubren **todo el historial** registrado
/// (la serie de la línea se recorta a los últimos [ciclosMax]); los encuentros,
/// la protección, los síntomas, los periodos iniciados y los días fértiles
/// cubren los últimos [meses] meses naturales, mes en curso incluido.
ReportsBoard buildReports(
  CalendarBoard board, {
  required DateTime today,
  int meses = 12,
  int ciclosMax = 12,
}) {
  final hoy = calendarDate(today);
  final ventana = [
    for (var i = meses - 1; i >= 0; i--) DateTime(hoy.year, hoy.month - i),
  ];
  final mesesVentana = ventana.toSet();

  final encuentrosVentana = [
    for (final encuentro in board.encuentros)
      if (mesesVentana.contains(_firstOfMonth(encuentro.encounterTime)))
        encuentro,
  ];

  final encuentrosPorMes = <DateTime, List<EncounterWithWomen>>{};
  for (final encuentro in encuentrosVentana) {
    (encuentrosPorMes[_firstOfMonth(encuentro.encounterTime)] ??=
            <EncounterWithWomen>[])
        .add(encuentro);
  }

  // Una pasada por mujer y mes, compartida por el informe individual y el
  // resumen mensual.
  final fertilesPorMujer = <int, Map<DateTime, int>>{
    for (final wc in board.women)
      wc.woman.id: {
        for (final mes in ventana) mes: _diasFertilesDelMes(wc.timeline, mes),
      },
  };

  final mujeres = [
    for (final wc in board.women)
      _womanReport(
        wc,
        encuentrosVentana,
        fertilesPorMujer[wc.woman.id] ?? const {},
        hoy: hoy,
        mesesVentana: mesesVentana,
        ciclosMax: ciclosMax,
      ),
  ];

  final periodosPorMes = <DateTime, int>{};
  for (final wc in board.women) {
    for (final periodo in wc.periodos) {
      final mes = _firstOfMonth(periodo.startDate);
      if (!mesesVentana.contains(mes)) continue;
      periodosPorMes[mes] = (periodosPorMes[mes] ?? 0) + 1;
    }
  }

  final mesesInforme = [
    for (final mes in ventana)
      MonthReport(
        mes: mes,
        encuentros: (encuentrosPorMes[mes] ?? const []).length,
        sinProteccion: (encuentrosPorMes[mes] ?? const [])
            .where(_sinProteccion)
            .length,
        diasFertiles: fertilesPorMujer.values.fold(
          0,
          (total, porMes) => total + (porMes[mes] ?? 0),
        ),
        periodos: periodosPorMes[mes] ?? 0,
      ),
  ];

  final duracionesCiclo = [
    for (final wc in board.women)
      for (final punto in _serieCiclos(wc)) punto.valor.round(),
  ];
  final duracionesMenstruacion = [
    for (final wc in board.women) ..._duracionesMenstruacion(wc),
  ];

  final encuentrosPorMujer = [
    for (final wc in board.women)
      BarraValor(
        etiqueta: wc.woman.name,
        valor: encuentrosVentana
            .where(
              (encuentro) =>
                  encuentro.participants.any((p) => p.womanId == wc.woman.id),
            )
            .length
            .toDouble(),
      ),
  ]..sort(_porValorDesc);

  final conMasEncuentros = encuentrosPorMujer
      .where((b) => b.valor > 0)
      .toList();
  final sinProteccionVentana = encuentrosVentana.where(_sinProteccion).length;

  final globales = ReportKpis(
    perfiles: board.women.length,
    ciclos: duracionesCiclo.length,
    encuentros: encuentrosVentana.length,
    encuentrosSinProteccion: sinProteccionVentana,
    diasFertiles: fertilesPorMujer.values.fold(
      0,
      (total, porMes) => total + porMes.values.fold(0, (a, b) => a + b),
    ),
    mediaCiclo: _media(duracionesCiclo),
    mediaMenstruacion: _media(duracionesMenstruacion),
    porcentajeSinProteccion: _porcentaje(
      sinProteccionVentana,
      encuentrosVentana.length,
    ),
    mujerConMasEncuentros: conMasEncuentros.isEmpty
        ? null
        : conMasEncuentros.first.etiqueta,
    maxEncuentros: conMasEncuentros.isEmpty
        ? 0
        : conMasEncuentros.first.valor.toInt(),
  );

  return ReportsBoard(
    globales: globales,
    mujeres: mujeres,
    meses: mesesInforme,
    proteccion: _proteccion(encuentrosVentana),
    encuentrosPorMujer: encuentrosPorMujer,
  );
}

WomanReport _womanReport(
  WomanCalendar wc,
  List<EncounterWithWomen> encuentrosVentana,
  Map<DateTime, int> fertilesPorMes, {
  required DateTime hoy,
  required Set<DateTime> mesesVentana,
  required int ciclosMax,
}) {
  final serieCompleta = _serieCiclos(wc);
  final serie = serieCompleta.length > ciclosMax
      ? serieCompleta.sublist(serieCompleta.length - ciclosMax)
      : serieCompleta;

  final encuentros = [
    for (final encuentro in encuentrosVentana)
      if (encuentro.participants.any((p) => p.womanId == wc.woman.id))
        encuentro,
  ]..sort((a, b) => b.encounterTime.compareTo(a.encounterTime));

  final duracionesCiclo = [for (final punto in serieCompleta) punto.valor];
  final sinProteccion = encuentros.where(_sinProteccion).length;

  return WomanReport(
    woman: wc.woman,
    kpis: ReportKpis(
      perfiles: 1,
      ciclos: serieCompleta.length,
      encuentros: encuentros.length,
      encuentrosSinProteccion: sinProteccion,
      diasFertiles: fertilesPorMes.values.fold(0, (a, b) => a + b),
      mediaCiclo: _media(duracionesCiclo),
      mediaMenstruacion: _media(_duracionesMenstruacion(wc)),
      porcentajeSinProteccion: _porcentaje(sinProteccion, encuentros.length),
    ),
    ciclos: serie,
    sintomas: _sintomas(wc, mesesVentana),
    proteccion: _proteccion(encuentros),
    encuentros: encuentros,
    proximoPeriodo: _proximoPeriodo(wc.timeline, hoy),
  );
}

/// Duración de cada ciclo cerrado, por fecha de cierre ascendente.
List<PuntoSerie> _serieCiclos(WomanCalendar wc) {
  final inicios = [
    for (final periodo in wc.periodos) calendarDate(periodo.startDate),
  ]..sort();
  return [
    // Inicios duplicados (p. ej. vía importación) no generan ciclos de
    // longitud cero.
    for (var i = 1; i < inicios.length; i++)
      if (inicios[i] != inicios[i - 1])
        PuntoSerie(
          fecha: inicios[i],
          valor: daysBetween(inicios[i - 1], inicios[i]).toDouble(),
        ),
  ];
}

List<int> _duracionesMenstruacion(WomanCalendar wc) => [
  for (final periodo in wc.periodos)
    if (periodo.endDate != null)
      daysBetween(
            calendarDate(periodo.startDate),
            calendarDate(periodo.endDate!),
          ) +
          1,
];

/// Frecuencia por tipo de síntoma en la ventana, de mayor a menor.
List<BarraValor> _sintomas(WomanCalendar wc, Set<DateTime> mesesVentana) {
  final conteo = <String, int>{};
  for (final evento in wc.eventos) {
    if (evento.type != TrackingEventType.symptom) continue;
    if (!mesesVentana.contains(_firstOfMonth(evento.date))) continue;
    final tipo = evento.symptomType ?? '';
    conteo[tipo] = (conteo[tipo] ?? 0) + 1;
  }

  final barras = [
    for (final entry in conteo.entries)
      BarraValor(etiqueta: entry.key, valor: entry.value.toDouble()),
  ];
  barras.sort(_porValorDesc);
  return barras;
}

/// Reparto por tipo de protección: primero el orden canónico, después el resto.
List<BarraValor> _proteccion(List<EncounterWithWomen> encuentros) {
  final conteo = <String, int>{};
  for (final encuentro in encuentros) {
    conteo[encuentro.protection] = (conteo[encuentro.protection] ?? 0) + 1;
  }

  final barras = <BarraValor>[];
  for (final opcion in protectionOptions) {
    final total = conteo.remove(opcion) ?? 0;
    if (total > 0) {
      barras.add(BarraValor(etiqueta: opcion, valor: total.toDouble()));
    }
  }

  final resto = conteo.entries.where((entry) => entry.value > 0).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  for (final entry in resto) {
    barras.add(BarraValor(etiqueta: entry.key, valor: entry.value.toDouble()));
  }
  return barras;
}

DateTime? _proximoPeriodo(CycleTimeline timeline, DateTime hoy) {
  for (final span in timeline.spans) {
    if (span.start.isAfter(hoy)) return span.start;
  }
  return null;
}

int _diasFertilesDelMes(CycleTimeline timeline, DateTime mes) {
  final inicio = DateTime(mes.year, mes.month);
  final fin = DateTime(mes.year, mes.month + 1, 0);
  var dias = 0;
  for (var day = inicio; !day.isAfter(fin); day = addDays(day, 1)) {
    if (timeline.isFertileOn(day)) dias++;
  }
  return dias;
}

bool _sinProteccion(EncounterWithWomen encuentro) =>
    encuentro.protection == noProtection;

int _porValorDesc(BarraValor a, BarraValor b) => a.valor != b.valor
    ? b.valor.compareTo(a.valor)
    : a.etiqueta.compareTo(b.etiqueta);

double _media(List<num> valores) {
  if (valores.isEmpty) return 0;
  var suma = 0.0;
  for (final valor in valores) {
    suma += valor.toDouble();
  }
  return suma / valores.length;
}

double _porcentaje(int parte, int total) =>
    total == 0 ? 0 : parte * 100 / total;

DateTime _firstOfMonth(DateTime value) => DateTime(value.year, value.month);
