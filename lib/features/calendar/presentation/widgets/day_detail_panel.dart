import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../prediction/domain/cycle_phase.dart';
import '../../../prediction/domain/mood_forecast.dart';
import '../../domain/calendar_board.dart';

/// Detalle del día seleccionado: estado de cada mujer, registros y encuentros.
class DayDetailPanel extends StatelessWidget {
  const DayDetailPanel({super.key, required this.day, required this.details});

  final DateTime day;
  final List<DayDetail> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMEEEEd('es_ES').format(day),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (details.isEmpty)
          Text('Sin perfiles.', style: theme.textTheme.bodyMedium)
        else
          for (final detail in details) _WomanDayTile(detail: detail),
      ],
    );
  }
}

class _WomanDayTile extends StatelessWidget {
  const _WomanDayTile({required this.detail});

  final DayDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(detail.woman.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(detail.woman.emoji),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      detail.woman.name,
                      style: theme.textTheme.titleSmall?.copyWith(color: color),
                    ),
                    if (detail.esEstimado) ...[
                      const SizedBox(width: 6),
                      Text(
                        'estimado',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(_estado(detail), style: theme.textTheme.bodySmall),
                for (final evento in detail.eventos)
                  Text(
                    '${evento.icon ?? ''} ${evento.title}'.trim(),
                    style: theme.textTheme.bodySmall,
                  ),
                for (final encuentro in detail.encuentros)
                  Text(
                    '⚡ Encuentro · ${encuentro.participantNames} · '
                    '${encuentro.protection}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _estado(DayDetail detail) {
    final fase = detail.fase;
    if (fase == null) return 'Sin datos de ciclo';
    final nombre = nombreFase(fase);
    if (!detail.fertil || fase == CyclePhase.ventanaFertil) return nombre;
    return '$nombre · ventana fértil';
  }
}
