import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  bool _saving = false;

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
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      _startDate = calendarDate(_startDate);
      _endDate = _endDate == null ? null : calendarDate(_endDate!);
      if (!isValidDate(_startDate)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodStartFuture)));
        return;
      }
      if (!isValidDateRange(_startDate, _endDate)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodEndBeforeStart)));
        return;
      }
      if (!isValidFlowLevel(_flowLevel)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodFlowRange)));
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodSaveError)));
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
        title: Text(isEditing ? l10n.editPeriodTitle : l10n.periodFormTitle),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fecha inicio
            ListTile(
              title: Text(l10n.dateStartLabel),
              subtitle: Text(_formatDate(l10n, _startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),
            const Divider(),
            // Fecha fin
            ListTile(
              title: Text(l10n.dateEndOptionalLabel),
              subtitle: Text(
                _endDate != null
                    ? _formatDate(l10n, _endDate!)
                    : l10n.undefinedDate,
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
                  '${l10n.durationLabel}: ${l10n.daysCount(_endDate!.difference(_startDate).inDays + 1)}',
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
                    l10n.flowLevelLabel,
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
              label: Text(isEditing ? l10n.saveChanges : l10n.registerPeriod),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) =>
      DateFormat('dd/MM/yyyy', l10n.localeName).format(date);
}
