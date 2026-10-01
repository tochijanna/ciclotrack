import 'package:ciclotrack/features/medications/domain/medication_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nombre obligatorio y máximo de 80', () {
    expect(validateMedicationName('  '), isNotNull);
    expect(validateMedicationName('Hierro'), isNull);
    expect(validateMedicationName('a' * 80), isNull);
    expect(validateMedicationName('a' * 81), isNotNull);
  });
  test('dosis opcional y máximo de 60', () {
    expect(validateMedicationDose(''), isNull);
    expect(validateMedicationDose('a' * 60), isNull);
    expect(validateMedicationDose('a' * 61), isNotNull);
  });
  test('hora y minuto en sus límites', () {
    for (final hour in [0, 23]) {
      expect(validateMedicationHour(hour), isNull);
    }
    for (final hour in [-1, 24]) {
      expect(validateMedicationHour(hour), isNotNull);
    }
    for (final minute in [0, 59]) {
      expect(validateMedicationMinute(minute), isNull);
    }
    for (final minute in [-1, 60]) {
      expect(validateMedicationMinute(minute), isNotNull);
    }
  });
}
