/// Errores de validación de un medicamento, independientes del idioma.
enum MedicationFieldError {
  nameRequired,
  nameTooLong,
  doseTooLong,
  hourOutOfRange,
  minuteOutOfRange,
}

MedicationFieldError? validateMedicationName(String value) {
  if (value.trim().isEmpty) return MedicationFieldError.nameRequired;
  if (value.trim().length > 80) return MedicationFieldError.nameTooLong;
  return null;
}

MedicationFieldError? validateMedicationDose(String value) =>
    value.trim().length > 60 ? MedicationFieldError.doseTooLong : null;

MedicationFieldError? validateMedicationHour(int value) =>
    value < 0 || value > 23 ? MedicationFieldError.hourOutOfRange : null;

MedicationFieldError? validateMedicationMinute(int value) =>
    value < 0 || value > 59 ? MedicationFieldError.minuteOutOfRange : null;
