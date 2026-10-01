String? validateMedicationName(String value) {
  if (value.trim().isEmpty) return 'Introduce el nombre del medicamento';
  if (value.trim().length > 80) return 'El nombre admite hasta 80 caracteres';
  return null;
}

String? validateMedicationDose(String value) =>
    value.trim().length > 60 ? 'La dosis admite hasta 60 caracteres' : null;
String? validateMedicationHour(int value) =>
    value < 0 || value > 23 ? 'La hora debe estar entre 0 y 23' : null;
String? validateMedicationMinute(int value) =>
    value < 0 || value > 59 ? 'El minuto debe estar entre 0 y 59' : null;
