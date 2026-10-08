import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/tracking_drafts.dart';
import '../../domain/tracking_event.dart';
import '../../domain/tracking_options.dart';
import '../../domain/tracking_validators.dart';
import '../l10n.dart';
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
  bool _saving = false;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _date = e?.date ?? DateTime.now();
    final type = e?.symptomType;
    if (type != null && symptomTypes.contains(type)) {
      _type = type;
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
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      _date = calendarDate(_date);
      if (!isValidDate(_date)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.dateFuture)));
        return;
      }
      if (!isValidSymptomType(_type)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.symptomTypeInvalid)));
        return;
      }
      if (!isValidSeverity(_severity)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.severityRange)));
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.symptomSaveError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editSymptomTitle : l10n.symptomFormTitle),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fecha
            ListTile(
              title: Text(l10n.dateLabel),
              subtitle: Text(_formatDate(l10n, _date)),
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
                    l10n.symptomTypeLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: symptomTypes.map((type) {
                      return ChoiceChip(
                        label: Text(localizedSymptomType(l10n, type)),
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
                    l10n.intensityLevel(_severity),
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
                decoration: InputDecoration(
                  labelText: l10n.notesLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? l10n.saveChanges : l10n.registerSymptom),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) =>
      DateFormat('dd/MM/yyyy', l10n.localeName).format(date);
}
