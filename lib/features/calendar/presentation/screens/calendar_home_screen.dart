import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../views/board_view.dart';
import '../views/fertility_view.dart';

/// Contenedor de las vistas consolidadas.
///
/// La pestaña de encuentros se añade en la siguiente ola de la fase 7.
class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vistas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semana'),
              Tab(text: 'Mes'),
              Tab(text: 'Fertilidad'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BoardView(format: CalendarFormat.week),
            BoardView(format: CalendarFormat.month),
            FertilityView(),
          ],
        ),
      ),
    );
  }
}
