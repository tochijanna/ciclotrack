import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../prediction/presentation/providers/prediction_day_provider.dart';
import '../../domain/calendar_board.dart';
import '../providers/calendar_providers.dart';

/// Mujeres cuya ventana fértil intersecta la semana en curso.
class FertilityView extends ConsumerWidget {
  const FertilityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final boardAsync = ref.watch(calendarBoardProvider);
    final today = ref.watch(predictionDayProvider);
    final weekStart = startOfWeek(today);

    return boardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(l10n.calendarLoadError)),
      data: (board) {
        final entradas = fertileInWeek(board, weekStart);
        final formato = DateFormat('d MMM', l10n.localeName);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.calendarWeekRange(
                formato.format(weekStart),
                formato.format(_addDays(weekStart, 6)),
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (board.women.isEmpty)
              Text(l10n.calendarEmpty)
            else if (entradas.isEmpty)
              Text(l10n.fertilityWeekEmpty)
            else
              for (final entrada in entradas)
                _FertileTile(entry: entrada, today: today),
          ],
        );
      },
    );
  }
}

class _FertileTile extends StatelessWidget {
  const _FertileTile({required this.entry, required this.today});

  final FertileWeekEntry entry;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = Color(entry.woman.color);
    final formato = DateFormat('d MMM', l10n.localeName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(entry.woman.emoji),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.woman.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                        ),
                      ),
                      if (entry.esEstimado) ...[
                        const SizedBox(width: 6),
                        Text(
                          l10n.fertilityEstimatedF,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    l10n.fertilityWindowLabel(
                      formato.format(entry.ventanaInicio),
                      formato.format(entry.ventanaFin),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    l10n.ovulationDateLabel(formato.format(entry.ovulacion)),
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(_cuentaAtras(l10n), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cuentaAtras(AppLocalizations l10n) {
    final hoy = DateTime(today.year, today.month, today.day);
    if (hoy.isBefore(entry.ventanaInicio)) {
      final dias = entry.ventanaInicio.difference(hoy).inDays;
      return dias == 1
          ? l10n.fertilityStartsTomorrow
          : l10n.fertilityStartsIn(dias);
    }
    final restantes = entry.ventanaFin.difference(hoy).inDays;
    if (restantes <= 0) return l10n.fertilityLastDay;
    return l10n.fertilityInProgress(restantes);
  }
}

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);
