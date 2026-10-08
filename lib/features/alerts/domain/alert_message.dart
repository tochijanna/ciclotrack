/// Mensajes estructurados de alerta (solo datos, sin texto localizado).
///
/// El motor produce estas estructuras y la capa de datos las convierte en
/// título/cuerpo localizados mediante `AppLocalizations`.
sealed class AlertMessage {
  const AlertMessage();
}

/// Fertilidad inminente: ovulación mañana.
class FertilityImminentMessage extends AlertMessage {
  const FertilityImminentMessage({required this.initials, required this.days});

  final String initials;
  final int days;
}

/// Día de riesgo: hoy dentro de la ventana fértil.
class RiskDayMessage extends AlertMessage {
  const RiskDayMessage({
    required this.initials,
    required this.endsTomorrow,
    this.endsOn,
  });

  final String initials;
  final bool endsTomorrow;
  final DateTime? endsOn;
}

/// Periodo inminente: empieza mañana.
class PeriodImminentMessage extends AlertMessage {
  const PeriodImminentMessage({required this.initials});

  final String initials;
}

/// Fertilidad combinada: varias mujeres fértiles esta semana.
class CombinedFertilityMessage extends AlertMessage {
  const CombinedFertilityMessage({required this.initials});

  final List<String> initials;
}

/// Encuentro + fertilidad.
class EncounterFertilityMessage extends AlertMessage {
  const EncounterFertilityMessage({
    required this.initials,
    required this.encounterOn,
    this.extraDays,
  });

  final String initials;
  final DateTime encounterOn;
  final int? extraDays;
}

/// Advertencia post-encuentro.
class PostEncounterWarningMessage extends AlertMessage {
  const PostEncounterWarningMessage({
    required this.initials,
    required this.encounterOn,
    required this.periodOn,
  });

  final String initials;
  final DateTime encounterOn;
  final DateTime periodOn;
}

/// Encuentro múltiple con varias mujeres fértiles.
class MultiWomenFertilityMessage extends AlertMessage {
  const MultiWomenFertilityMessage({
    required this.initials,
    required this.encounterOn,
  });

  final List<String> initials;
  final DateTime encounterOn;
}

/// Rango fértil de una mujer para el resumen semanal.
class FertileRangeEntry {
  const FertileRangeEntry({
    required this.initials,
    required this.from,
    required this.to,
  });

  final String initials;
  final DateTime from;
  final DateTime to;
}

/// Resumen semanal de ventanas fértiles.
class CombinedWindowMessage extends AlertMessage {
  const CombinedWindowMessage({required this.entries});

  final List<FertileRangeEntry> entries;
}

/// Recordatorio de medicación.
class MedicationMessage extends AlertMessage {
  const MedicationMessage({required this.hour, required this.minute});

  final int hour;
  final int minute;
}
