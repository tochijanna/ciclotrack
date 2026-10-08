import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/encounter_draft.dart';
import '../../domain/encounter_options.dart';
import '../../domain/encounter_validators.dart';
import '../l10n.dart';
import '../providers/encounter_providers.dart';

class EncounterFormScreen extends ConsumerStatefulWidget {
  const EncounterFormScreen({super.key, this.encounterId});

  final int? encounterId;

  @override
  ConsumerState<EncounterFormScreen> createState() =>
      _EncounterFormScreenState();
}

class _EncounterFormScreenState extends ConsumerState<EncounterFormScreen> {
  late DateTime _encounterTime;
  String _protection = protectionOptions.first;
  String? _outcome;
  late final TextEditingController _notesCtrl;

  /// womanId → relationshipType seleccionado.
  final Map<int, String> _selectedWomen = {};
  bool _saving = false;

  bool get isEditing => widget.encounterId != null;

  @override
  void initState() {
    super.initState();
    _encounterTime = DateTime.now();
    _notesCtrl = TextEditingController();
    if (isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(encounterRepositoryProvider);
    final existing = await repo.getById(widget.encounterId!);
    if (existing == null || !mounted) return;
    setState(() {
      _encounterTime = existing.encounterTime;
      _protection = existing.protection;
      _outcome = existing.outcome;
      _notesCtrl.text = existing.notes;
      for (final p in existing.participants) {
        _selectedWomen[p.womanId] = p.relationshipType;
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _encounterTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_encounterTime),
    );
    if (time == null) return;
    setState(() {
      _encounterTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _applyToAll(String relationshipType) {
    setState(() {
      for (final womanId in _selectedWomen.keys) {
        _selectedWomen[womanId] = relationshipType;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final participants = _selectedWomen.entries
          .map(
            (e) => EncounterParticipantDraft(
              womanId: e.key,
              relationshipType: e.value,
            ),
          )
          .toList();

      final draft = EncounterDraft(
        encounterTime: _encounterTime,
        protection: _protection,
        participants: participants,
        outcome: _outcome,
        notes: _notesCtrl.text,
      );

      final errors = validateEncounterDraft(draft);
      if (!errors.isValid) {
        final msg =
            [
                  errors.encounterTime,
                  errors.protection,
                  errors.participants,
                  errors.outcome,
                  errors.relationshipType,
                ]
                .where((e) => e != null)
                .map((e) => encounterErrorText(l10n, e!))
                .join('\n');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
        return;
      }

      final repo = ref.read(encounterRepositoryProvider);
      if (isEditing) {
        await repo.update(widget.encounterId!, draft);
      } else {
        await repo.create(draft);
      }
      ref.invalidate(allEncountersProvider);
      ref.invalidate(encountersByWomanProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.encounterSaveError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final womenAsync = ref.watch(availableWomenForEncounterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editEncounterTitle : l10n.encounterFormTitle,
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
            // Fecha y hora
            ListTile(
              title: Text(l10n.dateTimeLabel),
              subtitle: Text(_formatDateTime(l10n, _encounterTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const Divider(),
            // Mujeres
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.participantsLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            womenAsync.when(
              data: (women) {
                if (women.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.encounterNoProfiles),
                  );
                }
                return Column(
                  children: women.map((profile) {
                    final selected = _selectedWomen.containsKey(
                      profile.woman.id,
                    );
                    return Column(
                      children: [
                        CheckboxListTile(
                          value: selected,
                          onChanged: (sel) {
                            setState(() {
                              if (sel == true) {
                                _selectedWomen[profile.woman.id] =
                                    relationshipTypeOptions.first;
                              } else {
                                _selectedWomen.remove(profile.woman.id);
                              }
                            });
                          },
                          title: Text(
                            '${profile.woman.emoji} ${profile.woman.name}',
                          ),
                          subtitle: Text(profile.tags.join(', ')),
                          secondary: CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(
                              profile.woman.color,
                            ).withValues(alpha: 0.2),
                            child: Text(
                              profile.woman.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        if (selected)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedWomen[profile.woman.id],
                              decoration: InputDecoration(
                                labelText: l10n.relationshipTypeLabel,
                                isDense: true,
                              ),
                              items: relationshipTypeOptions
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        localizedRelationship(l10n, t),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _selectedWomen[profile.woman.id] = v;
                                  });
                                }
                              },
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('${l10n.errorLabel}: $e'),
            ),
            // Atajo: aplicar a todas
            if (_selectedWomen.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    Text(l10n.applyToAll),
                    ...relationshipTypeOptions.map(
                      (t) => ActionChip(
                        label: Text(localizedRelationship(l10n, t)),
                        onPressed: () => _applyToAll(t),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            // Protección
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.protectionLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SegmentedButton<String>(
              segments: protectionOptions
                  .map(
                    (p) => ButtonSegment<String>(
                      value: p,
                      label: Text(localizedProtection(l10n, p)),
                    ),
                  )
                  .toList(),
              selected: {_protection},
              onSelectionChanged: (sel) =>
                  setState(() => _protection = sel.first),
            ),
            const Divider(),
            // Resultado
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.outcomeLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SegmentedButton<String?>(
              segments: [
                ButtonSegment(value: null, label: Text(l10n.outcomeNoneOption)),
                ...outcomeOptions
                    .skip(1)
                    .map(
                      (o) => ButtonSegment(
                        value: o,
                        label: Text(localizedOutcome(l10n, o)),
                      ),
                    ),
              ],
              selected: {_outcome},
              onSelectionChanged: (sel) => setState(() => _outcome = sel.first),
            ),
            const Divider(),
            // Notas
            Padding(
              padding: const EdgeInsets.all(8),
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
              label: Text(
                isEditing ? l10n.saveChanges : l10n.registerEncounter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(AppLocalizations l10n, DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm', l10n.localeName).format(dt);
}
