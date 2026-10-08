import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/tracking_event.dart';
import '../l10n.dart';

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
    final l10n = AppLocalizations.of(context);
    final title = trackingEventTitle(l10n, event);
    final subtitle = trackingEventSubtitle(l10n, event);

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
                  trackingEventIcon(event),
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
                            title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          _formatDate(l10n, event.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
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

  String _formatDate(AppLocalizations l10n, DateTime date) =>
      DateFormat('dd/MM/yyyy', l10n.localeName).format(date);
}
