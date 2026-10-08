import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/calendar_board.dart';
import '../../domain/day_mark.dart';
import 'day_marks.dart';

/// Cuadrícula de perfiles compartida por las vistas Semana y Mes.
class BoardCalendar extends StatelessWidget {
  const BoardCalendar({
    super.key,
    required this.board,
    required this.format,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final CalendarBoard board;
  final CalendarFormat format;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  /// Margen de marcas alrededor del día enfocado; cubre cualquier celda visible
  /// de una cuadrícula semanal o mensual sin recalcular al seleccionar un día.
  static const markMarginDays = 45;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final marks = marksByDay(
      board,
      desde: _addDays(focusedDay, -markMarginDays),
      hasta: _addDays(focusedDay, markMarginDays),
    );

    return TableCalendar<DayMark>(
      locale: Localizations.localeOf(context).toLanguageTag(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      focusedDay: focusedDay,
      calendarFormat: format,
      availableCalendarFormats: {
        CalendarFormat.week: l10n.calendarWeekTab,
        CalendarFormat.month: l10n.calendarMonthTab,
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      eventLoader: (day) => marks[_calendarDate(day)] ?? const [],
      calendarBuilders: CalendarBuilders<DayMark>(
        markerBuilder: (context, day, events) =>
            events.isEmpty ? null : DayMarks(day: day, marks: events),
      ),
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(3),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

DateTime _calendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);
