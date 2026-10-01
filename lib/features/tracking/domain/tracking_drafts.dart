/// Modelo inmutable para crear/editar un registro de periodo.
class PeriodDraft {
  const PeriodDraft({
    required this.startDate,
    this.endDate,
    this.flowLevel,
    this.notes = '',
  });

  final DateTime startDate;
  final DateTime? endDate;
  final int? flowLevel;
  final String notes;

  PeriodDraft copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? flowLevel,
    String? notes,
  }) {
    return PeriodDraft(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowLevel: flowLevel ?? this.flowLevel,
      notes: notes ?? this.notes,
    );
  }
}

/// Modelo inmutable para crear/editar un registro de ovulación.
class OvulationDraft {
  const OvulationDraft({
    required this.date,
    this.temperature,
    this.cervicalMucus,
    this.lhTest,
  });

  final DateTime date;
  final double? temperature;
  final String? cervicalMucus;
  final bool? lhTest;

  OvulationDraft copyWith({
    DateTime? date,
    double? temperature,
    String? cervicalMucus,
    bool? lhTest,
  }) {
    return OvulationDraft(
      date: date ?? this.date,
      temperature: temperature ?? this.temperature,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      lhTest: lhTest ?? this.lhTest,
    );
  }
}

/// Modelo inmutable para crear/editar un registro de síntoma.
class SymptomDraft {
  const SymptomDraft({
    required this.date,
    required this.type,
    this.severity = 1,
    this.notes = '',
  });

  final DateTime date;
  final String type;
  final int severity;
  final String notes;

  SymptomDraft copyWith({
    DateTime? date,
    String? type,
    int? severity,
    String? notes,
  }) {
    return SymptomDraft(
      date: date ?? this.date,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    );
  }
}
