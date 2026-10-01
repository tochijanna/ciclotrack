import 'package:flutter/material.dart';

import '../../domain/calendar_board.dart';
import '../../domain/day_mark.dart';
import 'day_marks.dart';

/// Leyenda de la cuadrícula: color por mujer y significado de cada forma.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key, required this.women});

  final List<CalendarWoman> women;

  static const _significados = <DayMarkKind, String>{
    DayMarkKind.menstruacion: 'Menstruación',
    DayMarkKind.ventanaFertil: 'Ventana fértil',
    DayMarkKind.ovulacion: 'Ovulación',
    DayMarkKind.ovulacionRegistrada: 'Ovulación registrada',
    DayMarkKind.sintoma: 'Síntoma',
    DayMarkKind.encuentro: 'Encuentro',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            for (final entry in _significados.entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkGlyph(
                    mark: DayMark(
                      womanId: 0,
                      color: color.toARGB32(),
                      kind: entry.key,
                    ),
                    size: 8,
                  ),
                  const SizedBox(width: 6),
                  Text(entry.value, style: theme.textTheme.bodySmall),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Las marcas atenuadas son proyecciones a partir de la media de ciclos.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
