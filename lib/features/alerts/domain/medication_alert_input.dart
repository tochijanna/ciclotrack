class MedicationAlertInput {
  const MedicationAlertInput({
    required this.id,
    required this.womanId,
    required this.name,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });
  final int id;
  final int womanId;
  final String name;
  final int hour;
  final int minute;
  final bool enabled;
}
