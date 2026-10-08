import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../encounters/presentation/l10n.dart' as encounters_l10n;
import '../../../tracking/presentation/l10n.dart' as tracking_l10n;
import '../../domain/report_models.dart';

/// Colores estables para las series y los sectores.
const _paleta = <Color>[
  Color(0xFF7E57C2),
  Color(0xFF42A5F5),
  Color(0xFF26A69A),
  Color(0xFFFFA726),
  Color(0xFFEF5350),
];

/// Evolución de la duración de cada ciclo.
class CiclosChart extends StatelessWidget {
  const CiclosChart({super.key, required this.puntos, this.altura = 200});

  final List<PuntoSerie> puntos;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (puntos.length < 2) {
      return _Aviso(l10n.chartNeedTwoCycles);
    }

    final theme = Theme.of(context);
    final valores = [for (final punto in puntos) punto.valor];
    final formato = DateFormat('MMM yy', l10n.localeName);

    return SizedBox(
      height: altura,
      child: LineChart(
        LineChartData(
          minY: _min(valores) - 2,
          maxY: _max(valores) + 2,
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < puntos.length; i++)
                  FlSpot(i.toDouble(), puntos[i].valor),
              ],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= puntos.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formato.format(puntos[index].fecha),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frecuencia de cada tipo de síntoma.
class SintomasChart extends StatelessWidget {
  const SintomasChart({super.key, required this.barras, this.altura = 220});

  final List<BarraValor> barras;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (barras.isEmpty) {
      return _Aviso(l10n.chartNoSymptoms);
    }

    final theme = Theme.of(context);
    final valores = [for (final barra in barras) barra.valor];

    return SizedBox(
      height: altura,
      child: BarChart(
        BarChartData(
          maxY: _max(valores) + 1,
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < barras.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: barras[i].valor,
                    color: theme.colorScheme.secondary,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: 1,
                getTitlesWidget: (value, meta) => _etiqueta(
                  context,
                  barras,
                  value,
                  rotar: true,
                  localize: (e) => tracking_l10n.localizedSymptomType(l10n, e),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Encuentros y encuentros sin protección de cada mes de la ventana.
class MesesChart extends StatelessWidget {
  const MesesChart({super.key, required this.meses, this.altura = 220});

  final List<MonthReport> meses;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hayDatos = meses.any(
      (mes) => mes.encuentros > 0 || mes.sinProteccion > 0,
    );
    if (!hayDatos) {
      return _Aviso(l10n.chartNoEncounters);
    }

    final maximo = meses.fold<int>(
      0,
      (total, mes) => mes.encuentros > total ? mes.encuentros : total,
    );
    final formato = DateFormat('MMM', l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: altura,
          child: BarChart(
            BarChartData(
              maxY: maximo + 1,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < meses.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: meses[i].encuentros.toDouble(),
                        color: theme.colorScheme.primary,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: meses[i].sinProteccion.toDouble(),
                        color: theme.colorScheme.error,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= meses.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formato.format(meses[index].mes),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _Leyenda(
              color: theme.colorScheme.primary,
              texto: l10n.chartLegendEncounters,
            ),
            _Leyenda(
              color: theme.colorScheme.error,
              texto: l10n.chartLegendUnprotected,
            ),
          ],
        ),
      ],
    );
  }
}

/// Reparto de encuentros por tipo de protección.
class ProteccionChart extends StatelessWidget {
  const ProteccionChart({super.key, required this.barras});

  final List<BarraValor> barras;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (barras.isEmpty) {
      return _Aviso(l10n.chartNoEncounters);
    }

    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: [
                for (var i = 0; i < barras.length; i++)
                  PieChartSectionData(
                    value: barras[i].valor,
                    color: _paleta[i % _paleta.length],
                    radius: 46,
                    title: barras[i].valor.round().toString(),
                    titleStyle: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < barras.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      _Punto(color: _paleta[i % _paleta.length]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          encounters_l10n.localizedProtection(
                            l10n,
                            barras[i].etiqueta,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        barras[i].valor.round().toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Encuentros registrados por mujer en la ventana.
class EncuentrosPorMujerChart extends StatelessWidget {
  const EncuentrosPorMujerChart({
    super.key,
    required this.barras,
    this.altura = 220,
  });

  final List<BarraValor> barras;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (barras.isEmpty || barras.every((barra) => barra.valor == 0)) {
      return _Aviso(l10n.chartNoEncounters);
    }

    final theme = Theme.of(context);
    final valores = [for (final barra in barras) barra.valor];

    return SizedBox(
      height: altura,
      child: BarChart(
        BarChartData(
          maxY: _max(valores) + 1,
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < barras.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: barras[i].valor,
                    color: theme.colorScheme.primary,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: 1,
                getTitlesWidget: (value, meta) =>
                    _etiqueta(context, barras, value, rotar: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _etiqueta(
  BuildContext context,
  List<BarraValor> barras,
  double value, {
  required bool rotar,
  String Function(String)? localize,
}) {
  final index = value.round();
  if (index < 0 || index >= barras.length) return const SizedBox.shrink();

  final raw = barras[index].etiqueta;
  final texto = Text(
    localize == null ? raw : localize(raw),
    style: Theme.of(context).textTheme.bodySmall,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: rotar ? Transform.rotate(angle: -0.6, child: texto) : texto,
  );
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Punto(color: color),
      const SizedBox(width: 6),
      Text(texto, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _Punto extends StatelessWidget {
  const _Punto({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(
      texto,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

double _max(List<double> valores) => valores.reduce((a, b) => a > b ? a : b);

double _min(List<double> valores) => valores.reduce((a, b) => a < b ? a : b);
