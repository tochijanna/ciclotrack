import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/report_models.dart';
import '../providers/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_charts.dart';

/// Reportes y estadísticas: globales o de una mujer concreta.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(reportsBoardProvider);
    final selectedId = ref.watch(selectedWomanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: boardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('No se pudieron cargar los reportes.')),
        data: (board) {
          if (board.mujeres.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Sin perfiles. Crea uno para ver los reportes.'),
              ),
            );
          }

          // Si el perfil seleccionado ya no existe, la vista vuelve a «Todas».
          final woman = board.womanById(selectedId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WomanSelector(board: board, selectedId: woman?.woman.id),
              const SizedBox(height: 16),
              if (woman == null)
                _GlobalSection(board: board)
              else
                _WomanSection(report: woman),
            ],
          );
        },
      ),
    );
  }
}

class _WomanSelector extends ConsumerWidget {
  const _WomanSelector({required this.board, required this.selectedId});

  final ReportsBoard board;
  final int? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void select(int? womanId) =>
        ref.read(selectedWomanProvider.notifier).select(womanId);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: selectedId == null,
              onSelected: (_) => select(null),
            ),
          ),
          for (final report in board.mujeres)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(report.woman.name),
                selected: selectedId == report.woman.id,
                onSelected: (_) => select(report.woman.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlobalSection extends StatelessWidget {
  const _GlobalSection({required this.board});

  final ReportsBoard board;

  @override
  Widget build(BuildContext context) {
    final globales = board.globales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Titulo('Global'),
        const SizedBox(height: 8),
        KpiGrid(
          cards: [
            KpiCard(label: 'Perfiles', value: '${globales.perfiles}'),
            KpiCard(
              label: 'Ciclos registrados',
              value: '${globales.ciclos}',
              hint: 'histórico',
            ),
            KpiCard(
              label: 'Duración media del ciclo',
              value: _dias(globales.mediaCiclo),
              hint: 'histórico',
            ),
            KpiCard(
              label: 'Duración media de la menstruación',
              value: _dias(globales.mediaMenstruacion),
              hint: 'periodos cerrados',
            ),
            KpiCard(
              label: 'Encuentros',
              value: '${globales.encuentros}',
              hint: '12 meses',
            ),
            KpiCard(
              label: 'Sin protección',
              value: '${globales.porcentajeSinProteccion.round()} %',
              hint:
                  '«Ninguno»: '
                  '${globales.encuentrosSinProteccion} de '
                  '${globales.encuentros}',
            ),
            KpiCard(
              label: 'Días fértiles',
              value: '${globales.diasFertiles}',
              hint: '12 meses, con proyecciones',
            ),
            if (globales.mujerConMasEncuentros != null)
              KpiCard(
                label: 'Más encuentros',
                value: globales.mujerConMasEncuentros!,
                hint: '${globales.maxEncuentros} encuentros',
              ),
          ],
        ),
        const SizedBox(height: 24),
        const _Titulo('Por mes'),
        MesesChart(meses: board.meses),
        const SizedBox(height: 8),
        _MesesDetalle(meses: board.meses),
        const SizedBox(height: 24),
        const _Titulo('Encuentros por mujer'),
        EncuentrosPorMujerChart(barras: board.encuentrosPorMujer),
        const SizedBox(height: 24),
        const _Titulo('Protección'),
        ProteccionChart(barras: board.proteccion),
      ],
    );
  }
}

class _WomanSection extends StatelessWidget {
  const _WomanSection({required this.report});

  final WomanReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = report.kpis;
    final color = Color(report.woman.color);
    final proximo = report.proximoPeriodo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(report.woman.emoji),
            ),
            const SizedBox(width: 12),
            Text(
              report.woman.name,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 16),
        KpiGrid(
          cards: [
            KpiCard(
              label: 'Ciclos registrados',
              value: '${kpis.ciclos}',
              hint: 'histórico',
            ),
            KpiCard(
              label: 'Duración media del ciclo',
              value: _dias(kpis.mediaCiclo),
              hint: 'histórico',
            ),
            KpiCard(
              label: 'Duración media de la menstruación',
              value: _dias(kpis.mediaMenstruacion),
              hint: 'periodos cerrados',
            ),
            KpiCard(
              label: 'Encuentros',
              value: '${kpis.encuentros}',
              hint: '12 meses',
            ),
            KpiCard(
              label: 'Sin protección',
              value: '${kpis.porcentajeSinProteccion.round()} %',
              hint:
                  '«Ninguno»: '
                  '${kpis.encuentrosSinProteccion} de ${kpis.encuentros}',
            ),
            KpiCard(
              label: 'Días fértiles',
              value: '${kpis.diasFertiles}',
              hint: '12 meses, con proyecciones',
            ),
            KpiCard(
              label: 'Próximo periodo',
              value: proximo == null
                  ? '—'
                  : DateFormat('d MMM', 'es_ES').format(proximo),
              hint: 'proyectado',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _Titulo('Evolución del ciclo'),
        CiclosChart(puntos: report.ciclos),
        const SizedBox(height: 24),
        const _Titulo('Síntomas recurrentes'),
        SintomasChart(barras: report.sintomas),
        const SizedBox(height: 24),
        const _Titulo('Protección'),
        ProteccionChart(barras: report.proteccion),
      ],
    );
  }
}

class _MesesDetalle extends StatelessWidget {
  const _MesesDetalle({required this.meses});

  final List<MonthReport> meses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formato = DateFormat('MMM yyyy', 'es_ES');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mes in meses)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${formato.format(mes.mes)} · ${mes.encuentros} encuentros · '
              '${mes.sinProteccion} sin protección · '
              '${mes.diasFertiles} días fértiles · ${mes.periodos} periodos',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto, style: Theme.of(context).textTheme.titleMedium);
}

String _dias(double valor) => valor == 0 ? '—' : '${valor.round()} días';
