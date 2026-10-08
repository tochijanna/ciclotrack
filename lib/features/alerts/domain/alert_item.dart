import 'alert_message.dart';
import 'alert_types.dart';

/// Reserva las alertas en [100000, 999999] para que su cancelación no borre
/// recordatorios personalizados, que usan IDs >= 1000000.
const alertNotificationIdBase = 100000;
const alertNotificationIdCount = 900000;

bool isAlertNotificationId(int id) =>
    id >= alertNotificationIdBase &&
    id < alertNotificationIdBase + alertNotificationIdCount;

/// Alerta programada individual. El texto visible se genera a partir de
/// [message] en la capa de datos, localizado.
class AlertItem {
  const AlertItem({
    required this.type,
    required this.fireDate,
    required this.message,
    required this.womanIds,
    this.medicationId,
    this.recurringDaily = false,
  });

  final int? medicationId;
  final AlertType type;
  final DateTime fireDate;
  final AlertMessage message;
  final List<int> womanIds;
  final bool recurringDaily;

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
