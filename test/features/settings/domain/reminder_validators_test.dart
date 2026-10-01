import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/settings/domain/reminder_validators.dart';

void main() {
  group('validateReminderMessage', () {
    test('rejects an empty or blank message', () {
      expect(validateReminderMessage(''), 'Escribe un mensaje');
      expect(validateReminderMessage('   '), 'Escribe un mensaje');
      expect(validateReminderMessage(null), 'Escribe un mensaje');
    });

    test('accepts up to 120 characters and rejects 121', () {
      expect(validateReminderMessage('a' * 120), isNull);
      expect(validateReminderMessage('a' * 121), 'Máximo 120 caracteres');
    });
  });

  group('validateCycleDayStart', () {
    test('rejects a missing day and day 0', () {
      expect(validateCycleDayStart(null), 'Introduce un día del ciclo');
      expect(validateCycleDayStart(0), 'El día inicial debe ser 1 o mayor');
    });

    test('accepts 1..60 and rejects 61', () {
      expect(validateCycleDayStart(1), isNull);
      expect(validateCycleDayStart(60), isNull);
      expect(validateCycleDayStart(61), 'El día inicial no puede superar 60');
    });
  });

  group('validateCycleDayEnd', () {
    test('rejects an end before the start', () {
      expect(
        validateCycleDayEnd(5, 4),
        'El día final no puede ser anterior al inicial',
      );
    });

    test('rejects an end after day 60', () {
      expect(validateCycleDayEnd(5, 61), 'El día final no puede superar 60');
    });

    test('accepts a single day and a range up to 60', () {
      expect(validateCycleDayEnd(5, 5), isNull);
      expect(validateCycleDayEnd(5, 60), isNull);
    });
  });

  group('validateReminderDraft', () {
    test('accepts a valid draft', () {
      const draft = ReminderDraft(
        message: 'Mejor evitar sexo',
        cycleDayStart: 5,
        cycleDayEnd: 7,
      );
      expect(validateReminderDraft(draft), isNull);
    });

    test('reports the first failing field', () {
      const draft = ReminderDraft(
        message: '',
        cycleDayStart: 0,
        cycleDayEnd: 0,
      );
      expect(validateReminderDraft(draft), 'Escribe un mensaje');
    });
  });

  group('CycleReminder', () {
    const range = CycleReminder(
      id: 1,
      womanId: 1,
      cycleDayStart: 5,
      cycleDayEnd: 7,
      message: 'Mejor evitar sexo',
      enabled: true,
    );

    test('adds the range to the body only when it spans several days', () {
      expect(range.notificationBody, 'Mejor evitar sexo (días 5-7 del ciclo)');
      expect(range.rangeLabel, 'Días 5-7 del ciclo');

      final single = range.copyWith(cycleDayEnd: 5);
      expect(single.notificationBody, 'Mejor evitar sexo');
      expect(single.rangeLabel, 'Día 5 del ciclo');
    });
  });

  group('nextReminderFire', () {
    test('recent period: fires on the cycle day of the current cycle', () {
      final fire = nextReminderFire(
        lastPeriodStart: DateTime(2026, 9, 1),
        cycleDay: 5,
        now: DateTime(2026, 9, 2, 12),
        cycleLength: 28,
        hour: 9,
        minute: 30,
      );
      expect(fire, DateTime(2026, 9, 5, 9, 30));
    });

    test('same day before the notify time still fires today', () {
      final fire = nextReminderFire(
        lastPeriodStart: DateTime(2026, 9, 1),
        cycleDay: 5,
        now: DateTime(2026, 9, 5, 8),
        cycleLength: 28,
      );
      expect(fire, DateTime(2026, 9, 5, 9));
    });

    test('occurrence already past: moves to the next cycle', () {
      final fire = nextReminderFire(
        lastPeriodStart: DateTime(2026, 9, 1),
        cycleDay: 5,
        now: DateTime(2026, 9, 5, 9),
        cycleLength: 28,
      );
      expect(fire, DateTime(2026, 10, 3, 9));
    });

    test('overdue cycle: skips as many cycles as needed', () {
      final fire = nextReminderFire(
        lastPeriodStart: DateTime(2026, 6, 1),
        cycleDay: 5,
        now: DateTime(2026, 9, 10),
        cycleLength: 30,
      );
      // 5 jun + 4 ciclos de 30 días.
      expect(fire, DateTime(2026, 10, 3, 9));
    });

    test('ignores the time of day stored in the period start', () {
      final fire = nextReminderFire(
        lastPeriodStart: DateTime(2026, 9, 1, 23, 59),
        cycleDay: 1,
        now: DateTime(2026, 8, 31),
        cycleLength: 28,
      );
      expect(fire, DateTime(2026, 9, 1, 9));
    });

    test('no period data: there is no cycle day to fire on', () {
      final fire = nextReminderFire(
        lastPeriodStart: null,
        cycleDay: 5,
        now: DateTime(2026, 9, 2),
        cycleLength: 28,
      );
      expect(fire, isNull);
    });
  });
}
