import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prediction/presentation/providers/prediction_providers.dart';
import '../../../prediction/presentation/widgets/prediction_card.dart';
import '../../../profiles/data/women_repository.dart';
import '../../domain/tracking_event.dart';
import '../providers/tracking_providers.dart';
import '../widgets/tracking_event_card.dart';
import 'period_form_screen.dart';
import 'ovulation_form_screen.dart';
import 'symptom_form_screen.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.profile});

  final WomanProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(trackingTimelineProvider(profile.woman.id));
    final predictionAsync = ref.watch(
      womanPredictionProvider(profile.woman.id),
    );
    final woman = profile.woman;
    final color = Color(woman.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(woman.emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            Text(woman.name),
          ],
        ),
      ),
      body: timelineAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _EmptyTrackingView(
              onAddPeriod: () =>
                  _navigateToForm(context, ref, _FormType.period),
              onAddOvulation: () =>
                  _navigateToForm(context, ref, _FormType.ovulation),
              onAddSymptom: () =>
                  _navigateToForm(context, ref, _FormType.symptom),
            );
          }
          final hasPrediction =
              predictionAsync.hasValue && predictionAsync.value != null;
          final totalItems = events.length + (hasPrediction ? 1 : 0);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(trackingTimelineProvider(woman.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                if (hasPrediction && index == 0) {
                  return PredictionCard(prediction: predictionAsync.value!);
                }
                final eventIndex = index - (hasPrediction ? 1 : 0);
                final event = events[eventIndex];
                return TrackingEventCard(
                  key: ValueKey('${event.type.name}_${event.id}'),
                  event: event,
                  onTap: () => _editEvent(context, ref, event),
                  onLongPress: () => _confirmDelete(context, ref, event),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🩸', style: TextStyle(fontSize: 24)),
              title: const Text('Periodo'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToForm(context, ref, _FormType.period);
              },
            ),
            ListTile(
              leading: const Text('🥚', style: TextStyle(fontSize: 24)),
              title: const Text('Ovulación'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToForm(context, ref, _FormType.ovulation);
              },
            ),
            ListTile(
              leading: const Text('📋', style: TextStyle(fontSize: 24)),
              title: const Text('Síntoma'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToForm(context, ref, _FormType.symptom);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(
    BuildContext context,
    WidgetRef ref,
    _FormType type, {
    TrackingEvent? event,
  }) {
    final womanId = profile.woman.id;
    Widget screen;
    switch (type) {
      case _FormType.period:
        screen = PeriodFormScreen(womanId: womanId, event: event);
        break;
      case _FormType.ovulation:
        screen = OvulationFormScreen(womanId: womanId, event: event);
        break;
      case _FormType.symptom:
        screen = SymptomFormScreen(womanId: womanId, event: event);
        break;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _editEvent(BuildContext context, WidgetRef ref, TrackingEvent event) {
    _FormType type;
    switch (event.type) {
      case TrackingEventType.period:
        type = _FormType.period;
        break;
      case TrackingEventType.ovulation:
        type = _FormType.ovulation;
        break;
      case TrackingEventType.symptom:
        type = _FormType.symptom;
        break;
    }
    _navigateToForm(context, ref, type, event: event);
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TrackingEvent event,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Eliminar "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      final repo = ref.read(trackingRepositoryProvider);
      switch (event.type) {
        case TrackingEventType.period:
          await repo.deletePeriod(event.id);
          break;
        case TrackingEventType.ovulation:
          await repo.deleteOvulation(event.id);
          break;
        case TrackingEventType.symptom:
          await repo.deleteSymptom(event.id);
          break;
      }
      ref.invalidate(trackingTimelineProvider(profile.woman.id));
    });
  }
}

enum _FormType { period, ovulation, symptom }

class _EmptyTrackingView extends StatelessWidget {
  const _EmptyTrackingView({
    required this.onAddPeriod,
    required this.onAddOvulation,
    required this.onAddSymptom,
  });

  final VoidCallback onAddPeriod;
  final VoidCallback onAddOvulation;
  final VoidCallback onAddSymptom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('Sin registros', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer registro de tracking',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onAddPeriod,
                icon: const Text('🩸'),
                label: const Text('Periodo'),
              ),
              FilledButton.icon(
                onPressed: onAddOvulation,
                icon: const Text('🥚'),
                label: const Text('Ovulación'),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddSymptom,
                icon: const Text('📋'),
                label: const Text('Síntoma'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
