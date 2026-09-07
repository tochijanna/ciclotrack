import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../domain/tracking_drafts.dart';
import '../../domain/tracking_event.dart';
import '../../domain/tracking_options.dart';
import '../../domain/tracking_validators.dart';
import '../providers/tracking_providers.dart';

class OvulationFormScreen extends ConsumerStatefulWidget {
  const OvulationFormScreen({super.key, required this.womanId, this.event});

  final int womanId;
  final TrackingEvent? event;

  @override
  ConsumerState<OvulationFormScreen> createState() =>
      _OvulationFormScreenState();
}

class _OvulationFormScreenState extends ConsumerState<OvulationFormScreen> {
  late DateTime _date;
  final _tempCtrl = TextEditingController();
  String? _cervicalMucus;
  bool? _lhTest;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _date = e?.date ?? DateTime.now();
    if (e?.temperature != null) {
      _tempCtrl.text = e!.temperature!.toStringAsFixed(1);
    }
    _cervicalMucus = e?.cervicalMucus;
    _lhTest = e?.lhTest;
  }

  @override
  void dispose() {
    _tempCtrl.dispose();
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

    double? temp;
    if (_tempCtrl.text.isNotEmpty) {
      temp = double.tryParse(_tempCtrl.text);
      if (!isValidTemperature(temp)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temperatura debe estar entre 34 y 40 °C'),
          ),
        );
        return;
      }
    }

    final draft = OvulationDraft(
      date: _date,
      temperature: temp,
      cervicalMucus: _cervicalMucus,
      lhTest: _lhTest,
    );

    final repo = ref.read(trackingRepositoryProvider);
    if (isEditing) {
      final db = ref.read(appDatabaseProvider);
      final existing = await (db.select(
        db.ovulationLogs,
      )..where((t) => t.id.equals(widget.event!.id))).getSingle();
      await repo.updateOvulation(existing, draft);
    } else {
      await repo.createOvulation(widget.womanId, draft);
    }

    ref.invalidate(trackingTimelineProvider(widget.womanId));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar ovulación' : 'Registrar ovulación'),
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
            // Temperatura
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _tempCtrl,
                decoration: const InputDecoration(
                  labelText: 'Temperatura basal (°C)',
                  hintText: '36.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            // Moco cervical
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moco cervical',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: cervicalMucusOptions.map((opt) {
                      return ChoiceChip(
                        label: Text(opt),
                        selected: _cervicalMucus == opt,
                        onSelected: (sel) =>
                            setState(() => _cervicalMucus = sel ? opt : null),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // LH test
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test LH',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('No realizado')),
                      ButtonSegment(value: true, label: Text('Positivo')),
                      ButtonSegment(value: false, label: Text('Negativo')),
                    ],
                    selected: {_lhTest},
                    onSelectionChanged: (sel) =>
                        setState(() => _lhTest = sel.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(
                isEditing ? 'Guardar cambios' : 'Registrar ovulación',
              ),
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
