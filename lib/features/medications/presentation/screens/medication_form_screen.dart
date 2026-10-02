import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/medication_validators.dart';
import '../providers/medication_providers.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.medication});
  final Medication? medication;
  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dose;
  int? _womanId;
  late TimeOfDay _time;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final medication = widget.medication;
    _name = TextEditingController(text: medication?.name ?? '');
    _dose = TextEditingController(text: medication?.dose ?? '');
    _womanId = medication?.womanId;
    _time = TimeOfDay(
      hour: medication?.hour ?? 9,
      minute: medication?.minute ?? 0,
    );
    _enabled = medication?.enabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(medicationRepositoryProvider)
          .save(
            id: widget.medication?.id,
            womanId: _womanId!,
            name: _name.text,
            dose: _dose.text,
            hour: _time.hour,
            minute: _time.minute,
            enabled: _enabled,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el medicamento')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(medicationWomenProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication == null
              ? 'Añadir medicamento'
              : 'Editar medicamento',
        ),
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudieron cargar los perfiles')),
        data: (women) {
          if (women.isEmpty) {
            return const Center(
              child: Text('Crea un perfil para añadir medicación'),
            );
          }
          final selected = women.any((p) => p.woman.id == _womanId)
              ? _womanId
              : null;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selected,
                  decoration: const InputDecoration(labelText: 'Mujer'),
                  items: [
                    for (final profile in women)
                      DropdownMenuItem(
                        value: profile.woman.id,
                        child: Text(profile.woman.name),
                      ),
                  ],
                  validator: (value) =>
                      value == null ? 'Selecciona una mujer' : null,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _womanId = value),
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Medicamento'),
                  validator: (value) => validateMedicationName(value ?? ''),
                  enabled: !_saving,
                ),
                TextFormField(
                  controller: _dose,
                  decoration: const InputDecoration(
                    labelText: 'Dosis (opcional)',
                  ),
                  validator: (value) => validateMedicationDose(value ?? ''),
                  enabled: !_saving,
                ),
                FormField<TimeOfDay>(
                  validator: (_) =>
                      validateMedicationHour(_time.hour) ??
                      validateMedicationMinute(_time.minute),
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Hora de la toma'),
                        subtitle: Text(
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _saving
                            ? null
                            : () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _time,
                                );
                                if (time != null && mounted) {
                                  setState(() => _time = time);
                                }
                              },
                      ),
                      if (field.errorText != null)
                        Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Activo'),
                  value: _enabled,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _enabled = value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Guardando…' : 'Guardar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
