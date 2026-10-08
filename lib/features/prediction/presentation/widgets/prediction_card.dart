import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/woman_prediction.dart';
import '../l10n.dart';

/// Tarjeta de predicción de fertilidad y humor para una mujer.
class PredictionCard extends StatelessWidget {
  const PredictionCard({super.key, required this.prediction});

  final WomanPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (prediction.estadoRiesgo == EstadoRiesgo.sinDatos) {
      return _SinDatosCard(l10n: l10n);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: estado de riesgo + día del ciclo
            _buildHeader(context, colorScheme, l10n),
            const Divider(height: 20),
            // Humor de hoy
            _buildMoodToday(context, colorScheme, l10n),
            const Divider(height: 20),
            // Fechas clave
            _buildKeyDates(context, l10n),
            // Pronóstico
            if (prediction.pronostico.isNotEmpty) ...[
              const Divider(height: 20),
              _buildForecast(context, l10n),
            ],
            // Estadísticas + disclaimer
            const Divider(height: 20),
            _buildStats(context, colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final estado = prediction.estadoRiesgo;
    final IconData icon;
    final Color color;

    switch (estado) {
      case EstadoRiesgo.periodoEnCurso:
        icon = Icons.water_drop;
        color = colorScheme.error;
        break;
      case EstadoRiesgo.diaDeRiesgo:
        icon = Icons.warning_amber;
        color = colorScheme.error;
        break;
      case EstadoRiesgo.posibleRetraso:
        icon = Icons.schedule;
        color = colorScheme.error;
        break;
      case EstadoRiesgo.fueraDeVentana:
        icon = Icons.check_circle_outline;
        color = colorScheme.primary;
        break;
      case EstadoRiesgo.sinDatos:
        icon = Icons.help_outline;
        color = colorScheme.outline;
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            riskLabel(l10n, estado),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (prediction.cicloActual != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.cycleDay(prediction.cicloActual!),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMoodToday(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final phase = prediction.faseHoy;

    return Row(
      children: [
        // Fase
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.phaseLabel(phaseLabel(l10n, phase)),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.moodLabel(moodHumor(l10n, phase)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                l10n.libidoLabel(moodLibido(l10n, phase)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (moodTip(l10n, phase) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    moodTip(l10n, phase)!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyDates(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        if (prediction.ovulacionEstimada != null)
          _DateRow(
            icon: '🥚',
            label: l10n.estimatedOvulation,
            value: _formatDate(l10n, prediction.ovulacionEstimada!),
            extra:
                prediction.rangoOvulacionInicio != null &&
                    prediction.rangoOvulacionFin != null
                ? '(${_formatShortDate(l10n, prediction.rangoOvulacionInicio!)} – ${_formatShortDate(l10n, prediction.rangoOvulacionFin!)})'
                : null,
          ),
        if (prediction.ventanaFertilInicio != null &&
            prediction.ventanaFertilFin != null)
          _DateRow(
            icon: '🔥',
            label: l10n.fertileWindowRisk,
            value:
                '${_formatShortDate(l10n, prediction.ventanaFertilInicio!)} – ${_formatShortDate(l10n, prediction.ventanaFertilFin!)}',
          ),
        if (prediction.periodoPrevisto != null)
          _DateRow(
            icon: '🩸',
            label: l10n.expectedPeriod,
            value: _formatDate(l10n, prediction.periodoPrevisto!),
          ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.upcomingDays,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        ...prediction.pronostico.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '${_formatShortDate(l10n, r.inicio)} – ${_formatShortDate(l10n, r.fin)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${phaseLabel(l10n, r.fase)} · ${moodHumor(l10n, r.fase)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cycleStats(
            prediction.ciclosReales,
            prediction.minCiclo,
            prediction.maxCiclo,
            prediction.mediaCiclo.toStringAsFixed(1),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (prediction.usaEstimacionPorDefecto)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.defaultEstimationWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 10,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.orientationDisclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime d) =>
      DateFormat('dd/MM/yyyy', l10n.localeName).format(d);

  String _formatShortDate(AppLocalizations l10n, DateTime d) =>
      DateFormat('dd/MM', l10n.localeName).format(d);
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
  });

  final String icon;
  final String label;
  final String value;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (extra != null) ...[
            const SizedBox(width: 4),
            Text(
              extra!,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SinDatosCard extends StatelessWidget {
  const _SinDatosCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.noDataCardBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
