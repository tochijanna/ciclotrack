import '../../calendar/domain/calendar_board.dart';
import '../../encounters/domain/encounter_event.dart';

/// Punto de una serie temporal (valor por fecha).
class PuntoSerie {
  const PuntoSerie({required this.fecha, required this.valor});

  final DateTime fecha;
  final double valor;
}

/// Valor etiquetado de un gráfico de barras.
class BarraValor {
  const BarraValor({required this.etiqueta, required this.valor});

  final String etiqueta;
  final double valor;
}

/// Indicadores agregados de un ámbito: un perfil concreto o todos.
class ReportKpis {
  const ReportKpis({
    required this.perfiles,
    required this.ciclos,
    required this.encuentros,
    required this.encuentrosSinProteccion,
    required this.diasFertiles,
    required this.mediaCiclo,
    required this.mediaMenstruacion,
    required this.porcentajeSinProteccion,
    this.mujerConMasEncuentros,
    this.maxEncuentros = 0,
  });

  /// Perfiles incluidos (1 en el informe de una mujer).
  final int perfiles;

  /// Ciclos cerrados de todo el historial: diferencias entre inicios de periodo.
  final int ciclos;

  /// Encuentros de la ventana de meses.
  final int encuentros;
  final int encuentrosSinProteccion;

  /// Días en ventana fértil dentro de la ventana de meses, proyecciones incluidas.
  final int diasFertiles;

  /// Duración media del ciclo en días (todo el historial). Cero sin datos.
  final double mediaCiclo;

  /// Duración media de la menstruación en días (solo periodos con fin registrado).
  final double mediaMenstruacion;

  /// Porcentaje de encuentros sin protección (0–100). Cero sin encuentros.
  final double porcentajeSinProteccion;

  /// Perfil con más encuentros en la ventana; `null` si no hay ninguno.
  final String? mujerConMasEncuentros;
  final int maxEncuentros;
}

/// Informe de una mujer.
class WomanReport {
  const WomanReport({
    required this.woman,
    required this.kpis,
    required this.ciclos,
    required this.sintomas,
    required this.proteccion,
    required this.encuentros,
    this.proximoPeriodo,
  });

  final CalendarWoman woman;
  final ReportKpis kpis;

  /// Duración de cada ciclo cerrado, por fecha ascendente (se recorta a los
  /// últimos ciclos para que la línea sea legible).
  final List<PuntoSerie> ciclos;

  /// Frecuencia por tipo de síntoma en la ventana, descendente.
  final List<BarraValor> sintomas;

  /// Encuentros por tipo de protección en la ventana, en el orden canónico.
  final List<BarraValor> proteccion;

  /// Encuentros de la ventana, del más reciente al más antiguo.
  final List<EncounterWithWomen> encuentros;

  /// Inicio del siguiente ciclo proyectado; `null` si no hay datos.
  final DateTime? proximoPeriodo;
}

/// Resumen de un mes natural.
class MonthReport {
  const MonthReport({
    required this.mes,
    required this.encuentros,
    required this.sinProteccion,
    required this.diasFertiles,
    required this.periodos,
  });

  /// Primer día del mes.
  final DateTime mes;
  final int encuentros;
  final int sinProteccion;
  final int diasFertiles;
  final int periodos;
}

/// Informe completo que consume la pantalla de reportes.
class ReportsBoard {
  const ReportsBoard({
    required this.globales,
    required this.mujeres,
    required this.meses,
    required this.proteccion,
    required this.encuentrosPorMujer,
  });

  final ReportKpis globales;
  final List<WomanReport> mujeres;

  /// Meses de la ventana, del más antiguo al más reciente.
  final List<MonthReport> meses;

  /// Reparto global de protección en la ventana, en el orden canónico.
  final List<BarraValor> proteccion;

  /// Encuentros de la ventana por mujer, descendente e incluyendo los ceros.
  final List<BarraValor> encuentrosPorMujer;

  /// Informe de una mujer, o `null` si su id no está en el tablero.
  WomanReport? womanById(int? womanId) {
    if (womanId == null) return null;
    for (final report in mujeres) {
      if (report.woman.id == womanId) return report;
    }
    return null;
  }
}
