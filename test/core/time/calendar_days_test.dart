import 'package:ciclotrack/core/time/calendar_days.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('daysBetween (insensible a DST)', () {
    test('primavera: día de 23 h (España, 2026-03-29) cuenta como 1', () {
      // El 29/03/2026 a las 02:00 UTC+1 pasa a 03:00 UTC+2.
      final antes = DateTime(2026, 3, 29);
      final despues = DateTime(2026, 3, 30);
      expect(daysBetween(antes, despues), 1);
    });

    test('otoño: día de 25 h (España, 2026-10-25) cuenta como 1', () {
      final antes = DateTime(2026, 10, 25);
      final despues = DateTime(2026, 10, 26);
      expect(daysBetween(antes, despues), 1);
    });

    test(
      'fechas con hora distinta de medianoche miden por día de calendario',
      () {
        expect(
          daysBetween(DateTime(2026, 3, 29, 23), DateTime(2026, 3, 30, 1)),
          1,
        );
      },
    );

    test('addDays cruza el cambio de hora sin desplazarse', () {
      expect(
        daysBetween(DateTime(2026, 3, 28), addDays(DateTime(2026, 3, 28), 2)),
        2,
      );
      expect(
        daysBetween(DateTime(2026, 10, 24), addDays(DateTime(2026, 10, 24), 2)),
        2,
      );
    });

    test('calendarDate elimina la hora', () {
      final d = calendarDate(DateTime(2026, 5, 4, 15, 30));
      expect(d, DateTime(2026, 5, 4));
    });
  });
}
