import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tracking_drafts.dart';
import '../../domain/tracking_event.dart';
import '../../domain/tracking_options.dart';
import '../../domain/tracking_validators.dart';
import '../providers/tracking_providers.dart';

class PeriodFormScreen extends ConsumerStatefulWidget {
  const PeriodFormScreen({super.key, required this.womanId, this.event});

  final int womanId;
  final TrackingEvent? event;

  @override
  ConsumerState<PeriodFormScreen> createState() => _PeriodFormScreenState();
}

class _PeriodFormScreenState extends ConsumerState<PeriodFormScreen> {
  late DateTime _startDate;
  DateTime? _endDate;
  int? _flowLevel;
  late final TextEditingController _notesCtrl;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _startDate = e?.date ?? DateTime.now();
    _endDate = e?.endDate;
    _flowLevel = e?.flowLevel;
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_endDate ?? _startDate);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!isValidDate(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de inicio no puede ser futura')),
      );
      return;
    }
    if (!isValidDateRange(_startDate, _endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin no puede ser anterior al inicio'),
        ),
      );
      return;
    }
    if (!isValidFlowLevel(_flowLevel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flujo debe estar entre 1 y 5')),
      );
      return;
    }

    final draft = PeriodDraft(
      startDate: _startDate,
      endDate: _endDate,
      flowLevel: _flowLevel,
      notes: _notesCtrl.text,
    );

    final repo = ref.read(trackingRepositoryProvider);
    if (isEditing) {
      await repo.updatePeriodById(widget.event!.id, draft);
    } else {
      await repo.createPeriod(widget.womanId, draft);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar periodo' : 'Registrar periodo'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fecha inicio
            ListTile(
              title: const Text('Fecha de inicio'),
              subtitle: Text(_formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),
            const Divider(),
            // Fecha fin
            ListTile(
              title: const Text('Fecha de fin (opcional)'),
              subtitle: Text(
                _endDate != null ? _formatDate(_endDate!) : 'Sin definir',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () => _pickDate(isStart: false),
            ),
            if (_endDate != null && _endDate!.isAfter(_startDate))
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Duración: ${_endDate!.difference(_startDate).inDays + 1} días',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Divider(),
            // Flujo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel de flujo',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: flowLevels
                        .map(
                          (level) => ButtonSegment<int>(
                            value: level,
                            label: Text('$level'),
                          ),
                        )
                        .toList(),
                    selected: _flowLevel != null ? {_flowLevel!} : {},
                    onSelectionChanged: (sel) =>
                        setState(() => _flowLevel = sel.first),
                    emptySelectionAllowed: true,
                  ),
                ],
              ),
            ),
            const Divider(),
            // Notas
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Guardar cambios' : 'Registrar periodo'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
