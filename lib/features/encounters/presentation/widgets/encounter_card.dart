import 'package:flutter/material.dart';

import '../../domain/encounter_event.dart';

/// Tarjeta para un encuentro en la lista.
class EncounterCard extends StatelessWidget {
  const EncounterCard({
    super.key,
    required this.encounter,
    this.onTap,
    this.onLongPress,
  });

  final EncounterWithWomen encounter;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      encounter.participantNames,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    _formatDateTime(encounter.encounterTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon: '🛡️',
                    label: encounter.protection,
                    color: colorScheme.primaryContainer,
                  ),
                  for (final p in encounter.participants)
                    _InfoChip(
                      icon: p.womanEmoji,
                      label: '${p.womanName}: ${p.relationshipType}',
                      color: Color(p.womanColor).withValues(alpha: 0.12),
                    ),
                  if (encounter.outcome != null && encounter.outcome != 'Nada')
                    _InfoChip(
                      icon: '📌',
                      label: encounter.outcome!,
                      color: colorScheme.errorContainer,
                    ),
                ],
              ),
              if (encounter.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    encounter.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Vista vacía cuando no hay encuentros.
class EmptyEncountersView extends StatelessWidget {
  const EmptyEncountersView({super.key, this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin encuentros',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tu primer encuentro',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Registrar encuentro'),
          ),
        ],
      ),
    );
  }
}
