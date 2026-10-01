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
    final boardAsync = ref.watch(calendarBoardProvider);
    final today = ref.watch(predictionDayProvider);
    final weekStart = startOfWeek(today);

    return boardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('No se pudieron cargar las vistas.')),
      data: (board) {
        final entradas = fertileInWeek(board, weekStart);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Semana del ${_formato.format(weekStart)} al '
              '${_formato.format(_addDays(weekStart, 6))}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (board.women.isEmpty)
              const Text('Sin perfiles. Crea uno para ver el calendario.')
            else if (entradas.isEmpty)
              const Text('Ninguna mujer en ventana fértil esta semana.')
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
    final color = Color(entry.woman.color);

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
                          'estimada',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Ventana: ${_formato.format(entry.ventanaInicio)} – '
                    '${_formato.format(entry.ventanaFin)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Ovulación: ${_formato.format(entry.ovulacion)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(_cuentaAtras(), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cuentaAtras() {
    final hoy = DateTime(today.year, today.month, today.day);
    if (hoy.isBefore(entry.ventanaInicio)) {
      final dias = entry.ventanaInicio.difference(hoy).inDays;
      return dias == 1 ? 'Empieza mañana' : 'Empieza en $dias días';
    }
    final restantes = entry.ventanaFin.difference(hoy).inDays;
    if (restantes <= 0) return 'Último día de ventana';
    return 'En curso, termina en $restantes ${restantes == 1 ? 'día' : 'días'}';
  }
}

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);

final _formato = DateFormat('d MMM', 'es_ES');
