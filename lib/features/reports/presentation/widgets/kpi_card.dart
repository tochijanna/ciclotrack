import 'package:flutter/material.dart';

/// Tarjeta de un indicador: valor grande, etiqueta y aclaración opcional.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;

  /// Aclara la ventana o el cálculo (por ejemplo «12 meses»).
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodyMedium),
            if (hint != null)
              Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Rejilla de tarjetas de KPI, dos por fila en pantallas de móvil.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [for (final card in cards) SizedBox(width: 160, child: card)],
  );
}
