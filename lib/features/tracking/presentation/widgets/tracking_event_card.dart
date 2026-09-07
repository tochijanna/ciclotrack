import 'package:flutter/material.dart';

import '../../domain/tracking_event.dart';

/// Tarjeta para un evento de la timeline.
class TrackingEventCard extends StatelessWidget {
  const TrackingEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onLongPress,
  });

  final TrackingEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _colorForType(event.type, colorScheme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  event.icon ?? '📋',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          _formatDate(event.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (event.subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          event.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (event.notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          event.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForType(TrackingEventType type, ColorScheme scheme) {
    switch (type) {
      case TrackingEventType.period:
        return scheme.error;
      case TrackingEventType.ovulation:
        return scheme.tertiary;
      case TrackingEventType.symptom:
        return scheme.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
