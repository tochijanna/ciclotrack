/// Tipo de evento para discriminar en la timeline.
enum TrackingEventType { period, ovulation, symptom }

/// Representa un evento combinado para la timeline.
///
/// Solo lleva datos crudos; los textos de presentación (título, subtítulo e
/// icono) se generan en la capa de presentación, localizados.
class TrackingEvent {
  const TrackingEvent({
    required this.type,
    required this.id,
    required this.womanId,
    required this.date,
    this.endDate,
    this.flowLevel,
    this.temperature,
    this.cervicalMucus,
    this.lhTest,
    this.severity,
    this.symptomType,
    this.notes = '',
  });

  final TrackingEventType type;
  final int id;
  final int womanId;
  final DateTime date;
  final DateTime? endDate;
  final int? flowLevel;
  final double? temperature;
  final String? cervicalMucus;
  final bool? lhTest;
  final int? severity;

  /// Tipo de síntoma tal y como está persistido (valor estable, sin traducir).
  final String? symptomType;
  final String notes;

  /// Crea un evento de periodo.
  factory TrackingEvent.period({
    required int id,
    required int womanId,
    required DateTime startDate,
    DateTime? endDate,
    int? flowLevel,
    String notes = '',
  }) {
    return TrackingEvent(
      type: TrackingEventType.period,
      id: id,
      womanId: womanId,
      date: startDate,
      endDate: endDate,
      flowLevel: flowLevel,
      notes: notes,
    );
  }

  /// Crea un evento de ovulación.
  factory TrackingEvent.ovulation({
    required int id,
    required int womanId,
    required DateTime date,
    double? temperature,
    String? cervicalMucus,
    bool? lhTest,
  }) {
    return TrackingEvent(
      type: TrackingEventType.ovulation,
      id: id,
      womanId: womanId,
      date: date,
      temperature: temperature,
      cervicalMucus: cervicalMucus,
      lhTest: lhTest,
    );
  }

  /// Crea un evento de síntoma.
  factory TrackingEvent.symptom({
    required int id,
    required int womanId,
    required DateTime date,
    required String type,
    int severity = 1,
    String notes = '',
  }) {
    return TrackingEvent(
      type: TrackingEventType.symptom,
      id: id,
      womanId: womanId,
      date: date,
      severity: severity,
      symptomType: type,
      notes: notes,
    );
  }
}
