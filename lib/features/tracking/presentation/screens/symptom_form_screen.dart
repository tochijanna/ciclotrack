import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tracking_drafts.dart';
import '../../domain/tracking_event.dart';
import '../../domain/tracking_options.dart';
import '../../domain/tracking_validators.dart';
import '../providers/tracking_providers.dart';

class SymptomFormScreen extends ConsumerStatefulWidget {
  const SymptomFormScreen({super.key, required this.womanId, this.event});

  final int womanId;
  final TrackingEvent? event;

  @override
  ConsumerState<SymptomFormScreen> createState() => _SymptomFormScreenState();
}

class _SymptomFormScreenState extends ConsumerState<SymptomFormScreen> {
  late DateTime _date;
  String _type = symptomTypes.first;
  int _severity = 1;
  late final TextEditingController _notesCtrl;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _date = e?.date ?? DateTime.now();
    if (e != null && symptomTypes.contains(e.title)) {
      _type = e.title;
    }
    _severity = e?.severity ?? 1;
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _save() async {
    if (!isValidDate(_date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha no puede ser futura')),
      );
      return;
    }
    if (!isValidSymptomType(_type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de síntoma no válido')),
      );
      return;
    }
    if (!isValidSeverity(_severity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intensidad debe estar entre 1 y 5')),
      );
      return;
    }

    final draft = SymptomDraft(
      date: _date,
      type: _type,
      severity: _severity,
      notes: _notesCtrl.text,
    );

    final repo = ref.read(trackingRepositoryProvider);
    if (isEditing) {
      await repo.updateSymptomById(widget.event!.id, draft);
    } else {
      await repo.createSymptom(widget.womanId, draft);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar síntoma' : 'Registrar síntoma'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fecha
            ListTile(
              title: const Text('Fecha'),
              subtitle: Text(_formatDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),
            // Tipo de síntoma
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipo de síntoma',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: symptomTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _type == type,
                        onSelected: (sel) {
                          if (sel) setState(() => _type = type);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Intensidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intensidad: $_severity/5',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_severity',
                    onChanged: (v) => setState(() => _severity = v.round()),
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
              label: Text(isEditing ? 'Guardar cambios' : 'Registrar síntoma'),
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
