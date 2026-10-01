import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../prediction/presentation/providers/prediction_day_provider.dart';
import '../../domain/calendar_board.dart';
import '../providers/calendar_providers.dart';
import '../widgets/board_calendar.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/day_detail_panel.dart';

/// Vista consolidada de todos los perfiles en una cuadrícula semanal o mensual.
///
/// Ignora el filtro de la lista de perfiles a propósito: la especificación pide
/// ver todos los perfiles en el mismo calendario.
class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key, required this.format});

  final CalendarFormat format;

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  DateTime? _focusedDay;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(calendarBoardProvider);
    final today = ref.watch(predictionDayProvider);
    final focusedDay = _focusedDay ?? today;
    final selectedDay = _selectedDay ?? today;

    return boardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('No se pudieron cargar las vistas.')),
      data: (board) {
        if (board.women.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Sin perfiles. Crea uno para ver el calendario.'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: [
            BoardCalendar(
              board: board,
              format: widget.format,
              focusedDay: focusedDay,
              selectedDay: selectedDay,
              onDaySelected: (selected, focused) => setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              }),
              onPageChanged: (focused) => setState(() => _focusedDay = focused),
            ),
            const SizedBox(height: 12),
            CalendarLegend(
              women: [for (final woman in board.women) woman.woman],
            ),
            const Divider(height: 32),
            DayDetailPanel(
              day: selectedDay,
              details: detailsFor(board, selectedDay),
            ),
          ],
        );
      },
    );
  }
}
