import 'package:ciclotrack/l10n/app_localizations.dart';

import '../domain/cycle_phase.dart';
import '../domain/woman_prediction.dart';

/// Nombre localizado de una fase del ciclo.
String phaseLabel(AppLocalizations l10n, CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruacion:
      return l10n.phaseMenstruation;
    case CyclePhase.follicular:
      return l10n.phaseFollicular;
    case CyclePhase.ventanaFertil:
      return l10n.phaseFertileWindow;
    case CyclePhase.ovulacion:
      return l10n.phaseOvulation;
    case CyclePhase.lutea:
      return l10n.phaseLuteal;
    case CyclePhase.luteaTardia:
      return l10n.phaseLateLuteal;
    case CyclePhase.retraso:
      return l10n.phaseDelayed;
  }
}

/// Etiqueta localizada del estado de riesgo.
String riskLabel(AppLocalizations l10n, EstadoRiesgo estado) {
  switch (estado) {
    case EstadoRiesgo.periodoEnCurso:
      return l10n.riskPeriodInProgress;
    case EstadoRiesgo.diaDeRiesgo:
      return l10n.riskRiskDay;
    case EstadoRiesgo.posibleRetraso:
      return l10n.riskPossibleDelay;
    case EstadoRiesgo.fueraDeVentana:
      return l10n.riskOutsideWindow;
    case EstadoRiesgo.sinDatos:
      return l10n.riskNoData;
  }
}

/// Humor orientativo localizado de una fase.
String moodHumor(AppLocalizations l10n, CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruacion:
      return l10n.moodMenstruationHumor;
    case CyclePhase.follicular:
      return l10n.moodFollicularHumor;
    case CyclePhase.ventanaFertil:
      return l10n.moodFertileHumor;
    case CyclePhase.ovulacion:
      return l10n.moodOvulationHumor;
    case CyclePhase.lutea:
      return l10n.moodLutealHumor;
    case CyclePhase.luteaTardia:
      return l10n.moodLateLutealHumor;
    case CyclePhase.retraso:
      return l10n.moodDelayedHumor;
  }
}

/// Libido orientativo localizado de una fase.
String moodLibido(AppLocalizations l10n, CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruacion:
      return l10n.moodMenstruationLibido;
    case CyclePhase.follicular:
      return l10n.moodFollicularLibido;
    case CyclePhase.ventanaFertil:
      return l10n.moodFertileLibido;
    case CyclePhase.ovulacion:
      return l10n.moodOvulationLibido;
    case CyclePhase.lutea:
      return l10n.moodLutealLibido;
    case CyclePhase.luteaTardia:
      return l10n.moodLateLutealLibido;
    case CyclePhase.retraso:
      return l10n.moodDelayedLibido;
  }
}

/// Consejo orientativo localizado de una fase; `null` cuando la fase no tiene.
String? moodTip(AppLocalizations l10n, CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruacion:
      return l10n.moodMenstruationTip;
    case CyclePhase.follicular:
      return l10n.moodFollicularTip;
    case CyclePhase.ventanaFertil:
      return l10n.moodFertileTip;
    case CyclePhase.ovulacion:
      return l10n.moodOvulationTip;
    case CyclePhase.lutea:
      return null;
    case CyclePhase.luteaTardia:
      return l10n.moodLateLutealTip;
    case CyclePhase.retraso:
      return l10n.moodDelayedTip;
  }
}
