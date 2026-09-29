import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../views/board_view.dart';

/// Contenedor de las vistas consolidadas.
///
/// Las pestañas de fertilidad y encuentros se añaden en las olas siguientes de
/// la fase 7.
class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vistas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semana'),
              Tab(text: 'Mes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BoardView(format: CalendarFormat.week),
            BoardView(format: CalendarFormat.month),
          ],
        ),
      ),
    );
  }
}
