import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/calendar_board.dart';
import '../../domain/day_mark.dart';
import 'day_marks.dart';

/// Leyenda de la cuadrícula: color por mujer y significado de cada forma.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key, required this.women});

  final List<CalendarWoman> women;

  String _significado(AppLocalizations l10n, DayMarkKind kind) {
    switch (kind) {
      case DayMarkKind.menstruacion:
        return l10n.legendMenstruation;
      case DayMarkKind.ventanaFertil:
        return l10n.legendFertileWindow;
      case DayMarkKind.ovulacion:
        return l10n.legendOvulation;
      case DayMarkKind.ovulacionRegistrada:
        return l10n.legendRegisteredOvulation;
      case DayMarkKind.sintoma:
        return l10n.legendSymptom;
      case DayMarkKind.encuentro:
        return l10n.legendEncounter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final woman in women)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkGlyph(
                    mark: DayMark(
                      womanId: woman.id,
                      color: woman.color,
                      kind: DayMarkKind.menstruacion,
                    ),
                    size: 8,
                  ),
                  const SizedBox(width: 6),
                  Text(woman.name, style: theme.textTheme.bodySmall),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final kind in DayMarkKind.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkGlyph(
                    mark: DayMark(
                      womanId: 0,
                      color: color.toARGB32(),
                      kind: kind,
                    ),
                    size: 8,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _significado(l10n, kind),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.legendProjectionNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
