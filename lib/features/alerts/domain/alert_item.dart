import 'alert_types.dart';

/// Alerta programada individual.
class AlertItem {
  const AlertItem({
    required this.type,
    required this.fireDate,
    required this.title,
    required this.body,
    required this.womanIds,
  });

  final AlertType type;
  final DateTime fireDate;
  final String title;
  final String body;
  final List<int> womanIds;

  /// Id determinista basado en tipo + mujeres + fecha (para deduplicación).
  int get id {
    final sorted = [...womanIds]..sort();
    final key =
        '${type.name}_${sorted.join(",")}_${fireDate.toIso8601String().substring(0, 10)}';
    return key.hashCode & 0x7FFFFFFF;
  }
}
