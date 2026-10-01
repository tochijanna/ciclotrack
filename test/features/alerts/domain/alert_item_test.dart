import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/alerts/domain/alert_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AlertItem item({
    List<int> women = const [2, 1],
    int? medicationId,
    AlertType type = AlertType.medicacion,
    DateTime? date,
  }) => AlertItem(
    type: type,
    fireDate: date ?? DateTime(2026, 9, 10, 12),
    title: 'Medicación',
    body: 'Toma',
    womanIds: women,
    medicationId: medicationId,
  );

  test('id determinista por tipo, mujeres, día y medicamento', () {
    expect(item().id, item(women: [1, 2]).id);
    expect(item().id, item(date: DateTime(2026, 9, 10, 18)).id);
    expect(item(medicationId: 1).id, item(medicationId: 1).id);
    expect(item(medicationId: 1).id, isNot(item(medicationId: 2).id));
  });

  test('todos los tipos y medicamentos quedan en el rango reservado', () {
    for (final type in AlertType.values) {
      for (var id = 0; id < 1000; id++) {
        final notificationId = item(
          type: type,
          medicationId: id,
          women: [id],
          date: DateTime(2026, 1, 1 + id),
        ).id;
        expect(notificationId, inInclusiveRange(100000, 999999));
        expect(isAlertNotificationId(notificationId), isTrue);
      }
    }
  });

  test('clasifica los límites y excluye IDs ajenos', () {
    expect(isAlertNotificationId(100000), isTrue);
    expect(isAlertNotificationId(999999), isTrue);
    for (final id in [-1, 0, 99999, 1000000, 1000003]) {
      expect(isAlertNotificationId(id), isFalse);
    }
  });
}
