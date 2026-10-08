import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/settings/domain/reminder_validators.dart';

void main() {
  group('validateReminderMessage', () {
    test('rejects an empty or blank message', () {
      expect(validateReminderMessage(''), ReminderFieldError.messageRequired);
      expect(
        validateReminderMessage('   '),
        ReminderFieldError.messageRequired,
      );
      expect(validateReminderMessage(null), ReminderFieldError.messageRequired);
    });

    test('accepts up to 120 characters and rejects 121', () {
      expect(validateReminderMessage('a' * 120), isNull);
      expect(
        validateReminderMessage('a' * 121),
        ReminderFieldError.messageTooLong,
      );
    });
  });

  group('validateCycleDayStart', () {
    test('rejects a missing day and day 0', () {
      expect(validateCycleDayStart(null), ReminderFieldError.startRequired);
      expect(validateCycleDayStart(0), ReminderFieldError.startTooSmall);
    });

    test('accepts 1..60 and rejects 61', () {
      expect(validateCycleDayStart(1), isNull);
      expect(validateCycleDayStart(60), isNull);
      expect(validateCycleDayStart(61), ReminderFieldError.startTooLarge);
    });
  });

  group('validateCycleDayEnd', () {
    test('rejects an end before the start', () {
      expect(validateCycleDayEnd(5, 4), ReminderFieldError.endBeforeStart);
    });

    test('rejects an end after day 60', () {
      expect(validateCycleDayEnd(5, 61), ReminderFieldError.endTooLarge);
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
      expect(validateReminderDraft(draft), ReminderFieldError.messageRequired);
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
