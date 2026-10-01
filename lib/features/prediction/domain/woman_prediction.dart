import 'cycle_phase.dart';

/// Estado de riesgo de hoy (dimensión fertilidad/prevención).
enum EstadoRiesgo {
  sinDatos,
  periodoEnCurso,
  diaDeRiesgo,
  fueraDeVentana,
  posibleRetraso,
}

/// Rango de fechas con fase, humor y libido para el pronóstico.
class RangoFase {
  const RangoFase({
    required this.inicio,
    required this.fin,
    required this.fase,
    required this.humor,
    required this.libido,
    this.consejo,
  });

  final DateTime inicio;
  final DateTime fin;
  final CyclePhase fase;
  final String humor;
  final String libido;
  final String? consejo;
}

/// Resultado completo de la predicción para una mujer.
class WomanPrediction {
  const WomanPrediction({
    required this.estadoRiesgo,
    required this.faseHoy,
    required this.humorHoy,
    required this.pronostico,
    required this.ovulacionEstimada,
    required this.rangoOvulacionInicio,
    required this.rangoOvulacionFin,
    required this.ventanaFertilInicio,
    required this.ventanaFertilFin,
    required this.periodoPrevisto,
    required this.minCiclo,
    required this.maxCiclo,
    required this.mediaCiclo,
    required this.ciclosReales,
    required this.usaEstimacionPorDefecto,
    this.duracionPeriodoEstimada = defaultPeriodDuration,
    this.cicloActual,
  });

  final EstadoRiesgo estadoRiesgo;
  final CyclePhase faseHoy;
  final String humorHoy;
  final List<RangoFase> pronostico;

  final DateTime? ovulacionEstimada;
  final DateTime? rangoOvulacionInicio;
  final DateTime? rangoOvulacionFin;
  final DateTime? ventanaFertilInicio;
  final DateTime? ventanaFertilFin;
  final DateTime? periodoPrevisto;

  final int minCiclo;
  final int maxCiclo;
  final double mediaCiclo;
  final int ciclosReales;
  final bool usaEstimacionPorDefecto;
  final int duracionPeriodoEstimada;

  /// Día actual del ciclo (1-indexado), o null si no hay datos.
  final int? cicloActual;
}
