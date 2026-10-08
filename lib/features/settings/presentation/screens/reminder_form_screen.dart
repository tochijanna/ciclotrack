import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/reminder_validators.dart';
import '../providers/reminder_providers.dart';

/// Pide el permiso de notificaciones y avisa si Android lo deniega. El
/// recordatorio se guarda igualmente: solo falta el aviso.
Future<void> ensureReminderPermission(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
) async {
  final granted = await ref.read(reminderNotifierProvider).requestPermission();
  if (granted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.reminderPermissionDenied)),
  );
}

class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, required this.womanId, this.reminder});

  final int womanId;
  final CycleReminder? reminder;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _messageCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late bool _enabled;
  bool _saving = false;

  bool get isEditing => widget.reminder != null;

  int? get _start => int.tryParse(_startCtrl.text.trim());

  /// El día final es opcional: vacío equivale a un recordatorio de un día.
  int? get _end {
    final text = _endCtrl.text.trim();
    return text.isEmpty ? _start : int.tryParse(text);
  }

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _messageCtrl = TextEditingController(text: r?.message ?? '');
    _startCtrl = TextEditingController(text: r?.cycleDayStart.toString() ?? '');
    _endCtrl = TextEditingController(text: r?.cycleDayEnd.toString() ?? '');
    _enabled = r?.enabled ?? true;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  String? _errorText(AppLocalizations l10n, ReminderFieldError? error) {
    switch (error) {
      case ReminderFieldError.messageRequired:
        return l10n.reminderMessageRequired;
      case ReminderFieldError.messageTooLong:
        return l10n.reminderMessageTooLong(reminderMessageMaxLength);
      case ReminderFieldError.startRequired:
        return l10n.reminderStartRequired;
      case ReminderFieldError.startTooSmall:
        return l10n.reminderStartTooSmall;
      case ReminderFieldError.startTooLarge:
        return l10n.reminderStartTooLarge(reminderMaxCycleDay);
      case ReminderFieldError.endRequired:
        return l10n.reminderEndRequired;
      case ReminderFieldError.endBeforeStart:
        return l10n.reminderEndBeforeStart;
      case ReminderFieldError.endTooLarge:
        return l10n.reminderEndTooLarge(reminderMaxCycleDay);
      case null:
        return null;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final draft = ReminderDraft(
        message: _messageCtrl.text,
        cycleDayStart: _start!,
        cycleDayEnd: _end!,
        enabled: _enabled,
      );

      final repo = ref.read(reminderRepositoryProvider);
      if (isEditing) {
        await repo.update(widget.reminder!, draft);
      } else {
        await repo.create(widget.womanId, draft);
      }
      if (_enabled) await ensureReminderPermission(ref, messenger, l10n);

      if (mounted) Navigator.pop(context);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reminderSaveError)));
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
          isEditing ? l10n.reminderEditTitle : l10n.reminderFormTitle,
        ),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('reminder_message'),
                controller: _messageCtrl,
                decoration: InputDecoration(
                  labelText: l10n.reminderMessageLabel,
                  hintText: l10n.reminderMessageHint,
                  border: const OutlineInputBorder(),
                ),
                maxLength: reminderMessageMaxLength,
                maxLines: 2,
                validator: (value) =>
                    _errorText(l10n, validateReminderMessage(value)),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('reminder_day_start'),
                      controller: _startCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.reminderStartLabel,
                        border: const OutlineInputBorder(),
                        errorMaxLines: 3,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (_) =>
                          _errorText(l10n, validateCycleDayStart(_start)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      key: const Key('reminder_day_end'),
                      controller: _endCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.reminderEndLabel,
                        border: const OutlineInputBorder(),
                        errorMaxLines: 3,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (_) => _start == null
                          ? null
                          : _errorText(l10n, validateCycleDayEnd(_start, _end)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reminderCycleNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.reminderEnabledLabel),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? l10n.saveChanges : l10n.reminderCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
