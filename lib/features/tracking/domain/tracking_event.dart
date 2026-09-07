/// Tipo de evento para discriminar en la timeline.
enum TrackingEventType { period, ovulation, symptom }

/// Representa un evento combinado para la timeline.
class TrackingEvent {
  const TrackingEvent({
    required this.type,
    required this.id,
    required this.womanId,
    required this.date,
    this.endDate,
    this.title = '',
    this.subtitle = '',
    this.icon,
    this.flowLevel,
    this.temperature,
    this.cervicalMucus,
    this.lhTest,
    this.severity,
    this.notes = '',
  });

  final TrackingEventType type;
  final int id;
  final int womanId;
  final DateTime date;
  final DateTime? endDate;
  final String title;
  final String subtitle;
  final String? icon;
  final int? flowLevel;
  final double? temperature;
  final String? cervicalMucus;
  final bool? lhTest;
  final int? severity;
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
      title: 'Periodo',
      subtitle: _formatPeriodSubtitle(startDate, endDate, flowLevel),
      icon: '🩸',
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
      title: 'Ovulación',
      subtitle: _formatOvulationSubtitle(temperature, cervicalMucus, lhTest),
      icon: '🥚',
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
      title: type,
      subtitle: 'Intensidad: $severity/5',
      icon: _symptomIcon(type),
      severity: severity,
      notes: notes,
    );
  }
}

String _formatPeriodSubtitle(DateTime start, DateTime? end, int? flow) {
  final parts = <String>[];
  if (end != null) {
    final days = end.difference(start).inDays + 1;
    parts.add('$days días');
  }
  if (flow != null) parts.add('Flujo: $flow/5');
  return parts.isEmpty ? '' : parts.join(' · ');
}

String _formatOvulationSubtitle(double? temp, String? mucus, bool? lh) {
  final parts = <String>[];
  if (temp != null) parts.add('${temp.toStringAsFixed(1)}°C');
  if (mucus != null && mucus.isNotEmpty) parts.add(mucus);
  if (lh == true) parts.add('LH +');
  return parts.isEmpty ? '' : parts.join(' · ');
}

String _symptomIcon(String type) {
  switch (type) {
    case 'Acné':
      return '🔴';
    case 'Dolor de pecho':
      return '💔';
    case 'Cansancio':
      return '😴';
    case 'Humor':
      return '😤';
    case 'Antojos':
      return '🍫';
    case 'Dolor abdominal':
      return '🤕';
    default:
      return '📋';
  }
}
