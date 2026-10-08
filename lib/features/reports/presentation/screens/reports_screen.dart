import 'package:ciclotrack/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final boardAsync = ref.watch(reportsBoardProvider);
    final selectedId = ref.watch(selectedWomanProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: boardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.reportsLoadError)),
        data: (board) {
          if (board.mujeres.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.reportsEmpty),
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
    final l10n = AppLocalizations.of(context);
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
              label: Text(l10n.reportsAll),
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
    final l10n = AppLocalizations.of(context);
    final globales = board.globales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Titulo(l10n.reportsGlobal),
        const SizedBox(height: 8),
        KpiGrid(
          cards: [
            KpiCard(label: l10n.kpiProfiles, value: '${globales.perfiles}'),
            KpiCard(
              label: l10n.kpiCycles,
              value: '${globales.ciclos}',
              hint: l10n.hintHistory,
            ),
            KpiCard(
              label: l10n.kpiAvgCycle,
              value: _dias(l10n, globales.mediaCiclo),
              hint: l10n.hintHistory,
            ),
            KpiCard(
              label: l10n.kpiAvgMenstruation,
              value: _dias(l10n, globales.mediaMenstruacion),
              hint: l10n.hintClosedPeriods,
            ),
            KpiCard(
              label: l10n.kpiEncounters,
              value: '${globales.encuentros}',
              hint: l10n.hintMonths12,
            ),
            KpiCard(
              label: l10n.kpiUnprotected,
              value: '${globales.porcentajeSinProteccion.round()} %',
              hint: l10n.hintUnprotected(
                globales.encuentrosSinProteccion,
                globales.encuentros,
              ),
            ),
            KpiCard(
              label: l10n.kpiFertileDays,
              value: '${globales.diasFertiles}',
              hint: l10n.hintFertile12,
            ),
            if (globales.mujerConMasEncuentros != null)
              KpiCard(
                label: l10n.kpiMostEncounters,
                value: globales.mujerConMasEncuentros!,
                hint: l10n.encountersCount(globales.maxEncuentros),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsPerMonth),
        MesesChart(meses: board.meses),
        const SizedBox(height: 8),
        _MesesDetalle(meses: board.meses),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsEncountersByWoman),
        EncuentrosPorMujerChart(barras: board.encuentrosPorMujer),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsProtection),
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
    final l10n = AppLocalizations.of(context);
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
              label: l10n.kpiCycles,
              value: '${kpis.ciclos}',
              hint: l10n.hintHistory,
            ),
            KpiCard(
              label: l10n.kpiAvgCycle,
              value: _dias(l10n, kpis.mediaCiclo),
              hint: l10n.hintHistory,
            ),
            KpiCard(
              label: l10n.kpiAvgMenstruation,
              value: _dias(l10n, kpis.mediaMenstruacion),
              hint: l10n.hintClosedPeriods,
            ),
            KpiCard(
              label: l10n.kpiEncounters,
              value: '${kpis.encuentros}',
              hint: l10n.hintMonths12,
            ),
            KpiCard(
              label: l10n.kpiUnprotected,
              value: '${kpis.porcentajeSinProteccion.round()} %',
              hint: l10n.hintUnprotected(
                kpis.encuentrosSinProteccion,
                kpis.encuentros,
              ),
            ),
            KpiCard(
              label: l10n.kpiFertileDays,
              value: '${kpis.diasFertiles}',
              hint: l10n.hintFertile12,
            ),
            KpiCard(
              label: l10n.kpiNextPeriod,
              value: proximo == null
                  ? '—'
                  : DateFormat('d MMM', l10n.localeName).format(proximo),
              hint: l10n.hintProjected,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsCycleEvolution),
        CiclosChart(puntos: report.ciclos),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsRecurringSymptoms),
        SintomasChart(barras: report.sintomas),
        const SizedBox(height: 24),
        _Titulo(l10n.reportsProtection),
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
    final l10n = AppLocalizations.of(context);
    final formato = DateFormat('MMM yyyy', l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mes in meses)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              l10n.reportsMonthDetail(
                formato.format(mes.mes),
                mes.encuentros,
                mes.sinProteccion,
                mes.diasFertiles,
                mes.periodos,
              ),
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

String _dias(AppLocalizations l10n, double valor) =>
    valor == 0 ? '—' : l10n.daysCount(valor.round());
