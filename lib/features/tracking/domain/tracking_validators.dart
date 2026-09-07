import 'tracking_options.dart';

/// Calcula la duración en días de un periodo (inclusivo).
/// Devuelve null si [endDate] es null o anterior a [startDate].
int? periodDuration(DateTime startDate, DateTime? endDate) {
  if (endDate == null) return null;
  if (endDate.isBefore(startDate)) return null;
  return endDate.difference(startDate).inDays + 1;
}

/// Valida que una fecha no sea futura.
bool isValidDate(DateTime date) => !date.isAfter(DateTime.now());

/// Valida que [end] no sea anterior a [start].
bool isValidDateRange(DateTime start, DateTime? end) {
  if (end == null) return true;
  return !end.isBefore(start);
}

/// Valida que el flujo esté en el rango 1..5.
bool isValidFlowLevel(int? level) {
  if (level == null) return true;
  return level >= 1 && level <= 5;
}

/// Valida que la severidad esté en el rango 1..5.
bool isValidSeverity(int severity) => severity >= 1 && severity <= 5;

/// Valida que el tipo de síntoma sea uno de los definidos.
bool isValidSymptomType(String type) => symptomTypes.contains(type);

/// Valida que la temperatura esté en un rango razonable (34-40 °C).
bool isValidTemperature(double? temp) {
  if (temp == null) return true;
  return temp >= 34.0 && temp <= 40.0;
}
