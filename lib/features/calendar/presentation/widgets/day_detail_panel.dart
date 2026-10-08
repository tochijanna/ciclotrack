import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../encounters/presentation/l10n.dart' as encounters_l10n;
import '../../../prediction/domain/cycle_phase.dart';
import '../../../prediction/presentation/l10n.dart' as prediction_l10n;
import '../../../tracking/presentation/l10n.dart' as tracking_l10n;
import '../../domain/calendar_board.dart';

/// Detalle del día seleccionado: estado de cada mujer, registros y encuentros.
class DayDetailPanel extends StatelessWidget {
  const DayDetailPanel({super.key, required this.day, required this.details});

  final DateTime day;
  final List<DayDetail> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMEEEEd(l10n.localeName).format(day),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (details.isEmpty)
          Text(l10n.dayNoProfiles, style: theme.textTheme.bodyMedium)
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
    final l10n = AppLocalizations.of(context);
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
                        l10n.fertilityEstimated,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(_estado(l10n, detail), style: theme.textTheme.bodySmall),
                for (final evento in detail.eventos)
                  Text(
                    '${tracking_l10n.trackingEventIcon(evento)} '
                    '${tracking_l10n.trackingEventTitle(l10n, evento)}',
                    style: theme.textTheme.bodySmall,
                  ),
                for (final encuentro in detail.encuentros)
                  Text(
                    '⚡ ${l10n.legendEncounter} · '
                    '${encuentro.participantNames} · '
                    '${encounters_l10n.localizedProtection(l10n, encuentro.protection)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _estado(AppLocalizations l10n, DayDetail detail) {
    final fase = detail.fase;
    if (fase == null) return l10n.dayNoCycleData;
    final nombre = prediction_l10n.phaseLabel(l10n, fase);
    if (!detail.fertil || fase == CyclePhase.ventanaFertil) return nombre;
    return '$nombre ${l10n.dayFertileSuffix}';
  }
}
