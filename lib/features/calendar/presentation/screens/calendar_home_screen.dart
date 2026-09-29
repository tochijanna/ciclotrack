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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vistas'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Semana'),
              Tab(text: 'Mes'),
              Tab(text: 'Fertilidad'),
              Tab(text: 'Encuentros'),
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
