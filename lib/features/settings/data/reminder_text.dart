import 'package:ciclotrack/l10n/app_localizations.dart';

import '../domain/reminder_validators.dart';

/// Rango legible y localizado de un recordatorio (p. ej. «Día 5 del ciclo»).
String reminderRangeLabel(AppLocalizations l10n, CycleReminder reminder) =>
    reminder.cycleDayEnd > reminder.cycleDayStart
    ? l10n.reminderDaysLabel(reminder.cycleDayStart, reminder.cycleDayEnd)
    : l10n.reminderDayLabel(reminder.cycleDayStart);

/// Cuerpo localizado de la notificación de un recordatorio.
String reminderNotificationBody(
  AppLocalizations l10n,
  CycleReminder reminder,
) => reminder.cycleDayEnd > reminder.cycleDayStart
    ? l10n.reminderBodyRange(
        reminder.message,
        reminder.cycleDayStart,
        reminder.cycleDayEnd,
      )
    : reminder.message;
