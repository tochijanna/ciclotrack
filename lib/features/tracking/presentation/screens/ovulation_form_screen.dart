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
  bool _saving = false;

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

      double? temp;
      final rawTemperature = _tempCtrl.text.trim();
      if (rawTemperature.isNotEmpty) {
        temp = double.tryParse(rawTemperature.replaceAll(',', '.'));
        if (temp == null || !isValidTemperature(temp)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.temperatureInvalid)));
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
        await repo.updateOvulationById(widget.event!.id, draft);
      } else {
        await repo.createOvulation(widget.womanId, draft);
      }

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ovulationSaveError)));
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
        title: Text(
          isEditing ? l10n.editOvulationTitle : l10n.ovulationFormTitle,
        ),
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
            // Temperatura
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _tempCtrl,
                decoration: InputDecoration(
                  labelText: l10n.temperatureBasalLabel,
                  hintText: '36.5',
                  border: const OutlineInputBorder(),
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
                    l10n.cervicalMucusLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: cervicalMucusOptions.map((opt) {
                      return ChoiceChip(
                        label: Text(localizedCervicalMucus(l10n, opt)),
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
                    l10n.lhTestLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool?>(
                    segments: [
                      ButtonSegment(value: null, label: Text(l10n.lhNotDone)),
                      ButtonSegment(value: true, label: Text(l10n.lhPositive)),
                      ButtonSegment(value: false, label: Text(l10n.lhNegative)),
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
              onPressed: _saving ? null : _save,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(
                isEditing ? l10n.saveChanges : l10n.registerOvulation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) =>
      DateFormat('dd/MM/yyyy', l10n.localeName).format(date);
}
