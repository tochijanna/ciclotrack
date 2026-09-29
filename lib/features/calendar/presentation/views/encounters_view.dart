import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../encounters/domain/encounter_event.dart';
import '../../../encounters/presentation/widgets/encounter_card.dart';
import '../../domain/calendar_board.dart';
import '../providers/calendar_providers.dart';

/// Encuentros por mujer: quién participó en cada uno y con qué resultado.
class EncountersBoardView extends ConsumerStatefulWidget {
  const EncountersBoardView({super.key});

  @override
  ConsumerState<EncountersBoardView> createState() =>
      _EncountersBoardViewState();
}

class _EncountersBoardViewState extends ConsumerState<EncountersBoardView> {
  int? _womanFilter;

  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(calendarBoardProvider);

    return boardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('No se pudieron cargar las vistas.')),
      data: (board) {
        if (board.women.isEmpty) {
          return const Center(child: Text('Sin perfiles.'));
        }

        final encuentros = _filtered(board);
        return Column(
          children: [
            _FilterRow(
              board: board,
              selected: _womanFilter,
              onSelected: (womanId) => setState(() => _womanFilter = womanId),
            ),
            Expanded(
              child: encuentros.isEmpty
                  ? Center(child: Text(_emptyMessage(board)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: encuentros.length,
                      itemBuilder: (context, index) =>
                          EncounterCard(encounter: encuentros[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<EncounterWithWomen> _filtered(CalendarBoard board) {
    final womanId = _womanFilter;
    if (womanId == null) return board.encuentros;
    return [
      for (final encuentro in board.encuentros)
        if (encuentro.participants.any((p) => p.womanId == womanId)) encuentro,
    ];
  }

  String _emptyMessage(CalendarBoard board) {
    final womanId = _womanFilter;
    if (womanId == null) return 'Sin encuentros registrados.';
    final name = board.women
        .firstWhere((woman) => woman.woman.id == womanId)
        .woman
        .name;
    return 'Sin encuentros con $name.';
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.board,
    required this.selected,
    required this.onSelected,
  });

  final CalendarBoard board;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('Todas (${board.encuentros.length})'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final woman in board.women)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '${woman.woman.name} (${_countFor(board, woman.woman.id)})',
                ),
                selected: selected == woman.woman.id,
                onSelected: (_) => onSelected(woman.woman.id),
              ),
            ),
        ],
      ),
    );
  }

  int _countFor(CalendarBoard board, int womanId) => board.encuentros
      .where(
        (encuentro) => encuentro.participants.any((p) => p.womanId == womanId),
      )
      .length;
}
