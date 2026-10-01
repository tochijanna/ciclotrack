import 'alert_types.dart';

/// Reserva las alertas en [100000, 999999] para que su cancelación no borre
/// recordatorios personalizados, que usan IDs >= 1000000.
const alertNotificationIdBase = 100000;
const alertNotificationIdCount = 900000;

bool isAlertNotificationId(int id) =>
    id >= alertNotificationIdBase &&
    id < alertNotificationIdBase + alertNotificationIdCount;

/// Alerta programada individual.
class AlertItem {
  const AlertItem({
    required this.type,
    required this.fireDate,
    required this.title,
    required this.body,
    required this.womanIds,
    this.medicationId,
  });

  final int? medicationId;
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
    final uniqueKey = medicationId == null ? key : '${key}_$medicationId';
    return alertNotificationIdBase +
        (uniqueKey.hashCode & 0x7FFFFFFF) % alertNotificationIdCount;
  }
}
