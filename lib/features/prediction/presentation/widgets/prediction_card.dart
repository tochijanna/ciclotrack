import 'package:flutter/material.dart';

import '../../domain/mood_forecast.dart';
import '../../domain/woman_prediction.dart';

/// Tarjeta de predicción de fertilidad y humor para una mujer.
class PredictionCard extends StatelessWidget {
  const PredictionCard({super.key, required this.prediction});

  final WomanPrediction prediction;

  @override
  Widget build(BuildContext context) {
    if (prediction.estadoRiesgo == EstadoRiesgo.sinDatos) {
      return _SinDatosCard();
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
            _buildHeader(context, colorScheme),
            const Divider(height: 20),
            // Humor de hoy
            _buildMoodToday(context, colorScheme),
            const Divider(height: 20),
            // Fechas clave
            _buildKeyDates(context),
            // Pronóstico
            if (prediction.pronostico.isNotEmpty) ...[
              const Divider(height: 20),
              _buildForecast(context),
            ],
            // Estadísticas + disclaimer
            const Divider(height: 20),
            _buildStats(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final estado = prediction.estadoRiesgo;
    final IconData icon;
    final Color color;
    final String label;

    switch (estado) {
      case EstadoRiesgo.periodoEnCurso:
        icon = Icons.water_drop;
        color = colorScheme.error;
        label = 'Periodo en curso';
        break;
      case EstadoRiesgo.diaDeRiesgo:
        icon = Icons.warning_amber;
        color = colorScheme.error;
        label = 'Día de riesgo';
        break;
      case EstadoRiesgo.posibleRetraso:
        icon = Icons.schedule;
        color = colorScheme.error;
        label = 'Posible retraso';
        break;
      case EstadoRiesgo.fueraDeVentana:
        icon = Icons.check_circle_outline;
        color = colorScheme.primary;
        label = 'Fuera de ventana fértil';
        break;
      case EstadoRiesgo.sinDatos:
        icon = Icons.help_outline;
        color = colorScheme.outline;
        label = 'Sin datos';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
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
              'Día ${prediction.cicloActual}',
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

  Widget _buildMoodToday(BuildContext context, ColorScheme colorScheme) {
    final phase = prediction.faseHoy;
    final mood = moodByPhase[phase]!;

    return Row(
      children: [
        // Fase
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fase: ${nombreFase(phase)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Humor: ${mood.humor}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Libido: ${mood.libido}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (mood.consejo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    mood.consejo!,
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

  Widget _buildKeyDates(BuildContext context) {
    return Column(
      children: [
        if (prediction.ovulacionEstimada != null)
          _DateRow(
            icon: '🥚',
            label: 'Ovulación estimada',
            value: _formatDate(prediction.ovulacionEstimada!),
            extra:
                prediction.rangoOvulacionInicio != null &&
                    prediction.rangoOvulacionFin != null
                ? '(${_formatShortDate(prediction.rangoOvulacionInicio!)} – ${_formatShortDate(prediction.rangoOvulacionFin!)})'
                : null,
          ),
        if (prediction.ventanaFertilInicio != null &&
            prediction.ventanaFertilFin != null)
          _DateRow(
            icon: '🔥',
            label: 'Ventana fértil (riesgo)',
            value:
                '${_formatShortDate(prediction.ventanaFertilInicio!)} – ${_formatShortDate(prediction.ventanaFertilFin!)}',
          ),
        if (prediction.periodoPrevisto != null)
          _DateRow(
            icon: '🩸',
            label: 'Periodo previsto',
            value: _formatDate(prediction.periodoPrevisto!),
          ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos días',
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
                    '${_formatShortDate(r.inicio)} – ${_formatShortDate(r.fin)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${nombreFase(r.fase)} · ${r.humor}',
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

  Widget _buildStats(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciclos: ${prediction.ciclosReales} · '
          'Min ${prediction.minCiclo} / Max ${prediction.maxCiclo} / '
          'Media ${prediction.mediaCiclo.toStringAsFixed(1)} días',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (prediction.usaEstimacionPorDefecto)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '⚠ Estimación por defecto (registra más periodos para mayor precisión)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 10,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Estimación orientativa según la fase del ciclo',
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatShortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
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
                'Registra al menos un periodo para ver la predicción',
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
