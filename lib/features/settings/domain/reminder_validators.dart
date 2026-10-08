/// Longitud máxima del mensaje de un recordatorio.
const int reminderMessageMaxLength = 120;

/// Último día del ciclo que admite un recordatorio.
const int reminderMaxCycleDay = 60;

/// Errores de validación de un recordatorio, independientes del idioma.
enum ReminderFieldError {
  messageRequired,
  messageTooLong,
  startRequired,
  startTooSmall,
  startTooLarge,
  endRequired,
  endBeforeStart,
  endTooLarge,
}

/// Recordatorio personalizado de una mujer (modelo de dominio, sin Drift).
class CycleReminder {
  const CycleReminder({
    required this.id,
    required this.womanId,
    required this.cycleDayStart,
    required this.cycleDayEnd,
    required this.message,
    required this.enabled,
  });

  final int id;
  final int womanId;
  final int cycleDayStart;
  final int cycleDayEnd;
  final String message;
  final bool enabled;

  CycleReminder copyWith({
    int? cycleDayStart,
    int? cycleDayEnd,
    String? message,
    bool? enabled,
  }) {
    return CycleReminder(
      id: id,
      womanId: womanId,
      cycleDayStart: cycleDayStart ?? this.cycleDayStart,
      cycleDayEnd: cycleDayEnd ?? this.cycleDayEnd,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Datos de alta o edición de un recordatorio.
class ReminderDraft {
  const ReminderDraft({
    required this.message,
    required this.cycleDayStart,
    required this.cycleDayEnd,
    this.enabled = true,
  });

  final String message;
  final int cycleDayStart;
  final int cycleDayEnd;
  final bool enabled;
}

/// Devuelve el error del mensaje, o null si es válido.
ReminderFieldError? validateReminderMessage(String? value) {
  final message = value?.trim() ?? '';
  if (message.isEmpty) return ReminderFieldError.messageRequired;
  if (message.length > reminderMessageMaxLength) {
    return ReminderFieldError.messageTooLong;
  }
  return null;
}

/// Devuelve el error del día inicial del ciclo, o null si es válido.
ReminderFieldError? validateCycleDayStart(int? start) {
  if (start == null) return ReminderFieldError.startRequired;
  if (start < 1) return ReminderFieldError.startTooSmall;
  if (start > reminderMaxCycleDay) return ReminderFieldError.startTooLarge;
  return null;
}

/// Devuelve el error del día final del ciclo, o null si es válido.
ReminderFieldError? validateCycleDayEnd(int? start, int? end) {
  if (end == null) return ReminderFieldError.endRequired;
  if (start != null && end < start) {
    return ReminderFieldError.endBeforeStart;
  }
  if (end > reminderMaxCycleDay) return ReminderFieldError.endTooLarge;
  return null;
}

/// Primer error del borrador, o null si se puede guardar.
ReminderFieldError? validateReminderDraft(ReminderDraft draft) {
  return validateReminderMessage(draft.message) ??
      validateCycleDayStart(draft.cycleDayStart) ??
      validateCycleDayEnd(draft.cycleDayStart, draft.cycleDayEnd);
}

/// Próximo momento en que cae el día [cycleDay] del ciclo, a la hora indicada.
///
/// El día 1 es [lastPeriodStart]. Si esa ocurrencia ya pasó respecto a [now],
/// se proyecta sumando ciclos de [cycleLength] días hasta dar con una futura.
/// Sin un inicio de periodo real no hay día 1 del que contar: devuelve null.
DateTime? nextReminderFire({
  required DateTime? lastPeriodStart,
  required int cycleDay,
  required DateTime now,
  required int cycleLength,
  int hour = 9,
  int minute = 0,
}) {
  if (lastPeriodStart == null || cycleDay < 1 || cycleLength < 1) return null;

  var offset = cycleDay - 1;
  DateTime fireAt() => DateTime(
    lastPeriodStart.year,
    lastPeriodStart.month,
    lastPeriodStart.day + offset,
    hour,
    minute,
  );

  var fire = fireAt();
  while (!fire.isAfter(now)) {
    offset += cycleLength;
    fire = fireAt();
  }
  return fire;
}
