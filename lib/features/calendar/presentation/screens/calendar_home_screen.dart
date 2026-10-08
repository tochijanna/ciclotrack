import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../views/board_view.dart';
import '../views/encounters_view.dart';
import '../views/fertility_view.dart';

/// Contenedor de las cuatro vistas consolidadas.
class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.calendarViewsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.calendarWeekTab),
              Tab(text: l10n.calendarMonthTab),
              Tab(text: l10n.calendarFertilityTab),
              Tab(text: l10n.calendarEncountersTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BoardView(format: CalendarFormat.week),
            BoardView(format: CalendarFormat.month),
            FertilityView(),
            EncountersBoardView(),
          ],
        ),
      ),
    );
  }
}
