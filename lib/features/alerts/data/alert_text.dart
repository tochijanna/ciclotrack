import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../domain/alert_message.dart';
import '../domain/alert_types.dart';

/// Etiqueta localizada de un tipo de alerta.
String alertTypeLabel(AppLocalizations l10n, AlertType type) {
  switch (type) {
    case AlertType.fertilidadInminente:
      return l10n.alertTypeFertilityImminent;
    case AlertType.diaDeRiesgo:
      return l10n.alertTypeRiskDay;
    case AlertType.periodoInminente:
      return l10n.alertTypePeriodImminent;
    case AlertType.fertilidadCombinada:
      return l10n.alertTypeCombinedFertility;
    case AlertType.encuentroFertilidad:
      return l10n.alertTypeEncounterFertility;
    case AlertType.advertenciaPostEncuentro:
      return l10n.alertTypePostEncounter;
    case AlertType.multiplesMujeresFertilidad:
      return l10n.alertTypeMultiFertility;
    case AlertType.ventanaCombinada:
      return l10n.alertTypeCombinedWindow;
    case AlertType.medicacion:
      return l10n.alertTypeMedication;
  }
}

/// Descripción localizada de un tipo de alerta.
String alertTypeDescription(AppLocalizations l10n, AlertType type) {
  switch (type) {
    case AlertType.fertilidadInminente:
      return l10n.alertDescFertilityImminent;
    case AlertType.diaDeRiesgo:
      return l10n.alertDescRiskDay;
    case AlertType.periodoInminente:
      return l10n.alertDescPeriodImminent;
    case AlertType.fertilidadCombinada:
      return l10n.alertDescCombinedFertility;
    case AlertType.encuentroFertilidad:
      return l10n.alertDescEncounterFertility;
    case AlertType.advertenciaPostEncuentro:
      return l10n.alertDescPostEncounter;
    case AlertType.multiplesMujeresFertilidad:
      return l10n.alertDescMultiFertility;
    case AlertType.ventanaCombinada:
      return l10n.alertDescCombinedWindow;
    case AlertType.medicacion:
      return l10n.alertDescMedication;
  }
}

/// Cuerpo localizado de una alerta a partir de su mensaje estructurado.
String alertBody(AppLocalizations l10n, AlertMessage message) {
  switch (message) {
    case FertilityImminentMessage(:final initials, :final days):
      return l10n.alertBodyFertilityImminent(initials, days);
    case RiskDayMessage(:final initials, :final endsTomorrow, :final endsOn):
      return endsTomorrow
          ? l10n.alertBodyRiskDayEndsTomorrow(initials)
          : l10n.alertBodyRiskDayEndsOn(initials, _shortDate(l10n, endsOn!));
    case PeriodImminentMessage(:final initials):
      return l10n.alertBodyPeriodImminent(initials);
    case CombinedFertilityMessage(:final initials):
      return l10n.alertBodyCombinedFertility(_joinNames(l10n, initials));
    case EncounterFertilityMessage(
      :final initials,
      :final encounterOn,
      :final extraDays,
    ):
      final weekday = _weekdayName(l10n, encounterOn);
      return extraDays == null
          ? l10n.alertBodyEncounterFertilityToday(initials, weekday)
          : l10n.alertBodyEncounterFertilityPlus(initials, weekday, extraDays);
    case PostEncounterWarningMessage(
      :final initials,
      :final encounterOn,
      :final periodOn,
    ):
      return l10n.alertBodyPostEncounter(
        initials,
        _weekdayName(l10n, encounterOn),
        _shortDate(l10n, periodOn),
      );
    case MultiWomenFertilityMessage(:final initials, :final encounterOn):
      return l10n.alertBodyMultiFertility(
        _joinNames(l10n, initials),
        _weekdayName(l10n, encounterOn),
      );
    case CombinedWindowMessage(:final entries):
      final text = entries
          .map(
            (entry) => l10n.alertEntryFertileRange(
              entry.initials,
              _shortDate(l10n, entry.from),
              _shortDate(l10n, entry.to),
            ),
          )
          .join('. ');
      return l10n.alertBodyCombinedWindow(text);
    case MedicationMessage(:final hour, :final minute):
      final time =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      return l10n.alertBodyMedication(time);
  }
}

String _shortDate(AppLocalizations l10n, DateTime d) =>
    DateFormat('d MMM', l10n.localeName).format(d);

String _weekdayName(AppLocalizations l10n, DateTime d) =>
    DateFormat('EEEE', l10n.localeName).format(d);

String _joinNames(AppLocalizations l10n, List<String> names) =>
    names.join(l10n.localeName.startsWith('en') ? ' and ' : ' y ');
