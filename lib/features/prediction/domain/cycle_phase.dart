import 'prediction_engine.dart';

/// Fases del ciclo menstrual, ordenadas cronológicamente.
enum CyclePhase {
  menstruacion,
  follicular,
  ventanaFertil,
  ovulacion,
  lutea,
  luteaTardia,
  retraso,
}

/// Días antes del periodo previsto que marcan el inicio de la fase PMS.
const pmsWindowDays = 4;

/// Duración por defecto de la menstruación cuando no hay datos.
const defaultPeriodDuration = 5;

/// Determina la fase del ciclo para un día concreto (1-indexado).
///
/// [prediction] contiene los días relativos del ciclo (ventana fértil, ovulación…).
/// [periodDuration] es la duración estimada de la menstruación (media o default).
/// [averageCycle] es la duración media del ciclo (para calcular el día previsto).
CyclePhase phaseForCycleDay(
  int cycleDay,
  CyclePrediction prediction,
  int periodDuration,
  double averageCycle,
) {
  final expectedPeriodDay = averageCycle.round();

  // Retraso: superamos el día previsto del siguiente periodo.
  if (cycleDay > expectedPeriodDay) return CyclePhase.retraso;

  // Lútea tardía (PMS): últimos N días antes del periodo previsto.
  final pmsStart = expectedPeriodDay - pmsWindowDays;
  if (cycleDay >= pmsStart && cycleDay <= expectedPeriodDay) {
    return CyclePhase.luteaTardia;
  }

  // Ovulación: día específico estimado.
  if (cycleDay == prediction.estimatedOvulationDay) {
    return CyclePhase.ovulacion;
  }

  // Ventana fértil (sin contar el día exacto de ovulación).
  if (cycleDay >= prediction.fertilityWindowStart &&
      cycleDay <= prediction.fertilityWindowEnd) {
    return CyclePhase.ventanaFertil;
  }

  // Menstruación.
  if (cycleDay <= periodDuration) return CyclePhase.menstruacion;

  // Lútea: post-ventana fértil hasta PMS.
  if (cycleDay > prediction.fertilityWindowEnd && cycleDay < pmsStart) {
    return CyclePhase.lutea;
  }

  // Folicular: post-menstruación hasta ventana fértil.
  return CyclePhase.follicular;
}
