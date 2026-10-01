import 'package:flutter_test/flutter_test.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_validators.dart';

void main() {
  group('periodDuration', () {
    test('calculates inclusive duration', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 5);
      expect(periodDuration(start, end), 5);
    });

    test('returns 1 for same day', () {
      final date = DateTime(2026, 9, 1);
      expect(periodDuration(date, date), 1);
    });

    test('returns null when endDate is null', () {
      expect(periodDuration(DateTime(2026, 9, 1), null), isNull);
    });

    test('returns null when endDate is before startDate', () {
      final start = DateTime(2026, 9, 5);
      final end = DateTime(2026, 9, 1);
      expect(periodDuration(start, end), isNull);
    });
  });

  group('isValidDate', () {
    test('accepts past date', () {
      expect(isValidDate(DateTime(2020, 1, 1)), isTrue);
    });

    test('accepts today', () {
      expect(isValidDate(DateTime.now()), isTrue);
    });

    test('rejects future date', () {
      expect(isValidDate(DateTime(2099, 1, 1)), isFalse);
    });
  });

  group('isValidDateRange', () {
    test('accepts null end', () {
      expect(isValidDateRange(DateTime(2026, 9, 1), null), isTrue);
    });

    test('accepts end after start', () {
      expect(
        isValidDateRange(DateTime(2026, 9, 1), DateTime(2026, 9, 5)),
        isTrue,
      );
    });

    test('accepts same day', () {
      final date = DateTime(2026, 9, 1);
      expect(isValidDateRange(date, date), isTrue);
    });

    test('rejects end before start', () {
      expect(
        isValidDateRange(DateTime(2026, 9, 5), DateTime(2026, 9, 1)),
        isFalse,
      );
    });
  });

  group('isValidFlowLevel', () {
    test('accepts null', () => expect(isValidFlowLevel(null), isTrue));
    test('accepts 1', () => expect(isValidFlowLevel(1), isTrue));
    test('accepts 5', () => expect(isValidFlowLevel(5), isTrue));
    test('rejects 0', () => expect(isValidFlowLevel(0), isFalse));
    test('rejects 6', () => expect(isValidFlowLevel(6), isFalse));
  });

  group('isValidSeverity', () {
    test('accepts 1', () => expect(isValidSeverity(1), isTrue));
    test('accepts 5', () => expect(isValidSeverity(5), isTrue));
    test('rejects 0', () => expect(isValidSeverity(0), isFalse));
    test('rejects 6', () => expect(isValidSeverity(6), isFalse));
  });

  group('isValidSymptomType', () {
    test('accepts known type', () {
      expect(isValidSymptomType('Acné'), isTrue);
    });

    test('rejects unknown type', () {
      expect(isValidSymptomType('Fiebre'), isFalse);
    });
  });

  group('isValidTemperature', () {
    test('accepts null', () => expect(isValidTemperature(null), isTrue));
    test('accepts 36.5', () => expect(isValidTemperature(36.5), isTrue));
    test('rejects 33', () => expect(isValidTemperature(33), isFalse));
    test('rejects 41', () => expect(isValidTemperature(41), isFalse));
  });
}
