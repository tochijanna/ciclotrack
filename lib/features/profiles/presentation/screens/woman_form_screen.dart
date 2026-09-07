import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/women_repository.dart';
import '../../domain/woman_draft.dart';
import '../../domain/woman_options.dart';
import '../../domain/woman_validator.dart';
import '../providers/women_providers.dart';

class WomanFormScreen extends ConsumerStatefulWidget {
  const WomanFormScreen({super.key, this.profile});

  final WomanProfile? profile;

  @override
  ConsumerState<WomanFormScreen> createState() => _WomanFormScreenState();
}

class _WomanFormScreenState extends ConsumerState<WomanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _initialsCtrl;
  late final TextEditingController _notesCtrl;
  late String _emoji;
  late int _color;
  late List<String> _tags;
  WomanValidationErrors _errors = const WomanValidationErrors();

  bool get isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    final w = widget.profile?.woman;
    _nameCtrl = TextEditingController(text: w?.name ?? '');
    _initialsCtrl = TextEditingController(text: w?.initials ?? '');
    _notesCtrl = TextEditingController(text: w?.privateNotes ?? '');
    _emoji = w?.emoji ?? '👩';
    _color = w?.color ?? 0xFFE91E63;
    _tags = List<String>.from(widget.profile?.tags ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _initialsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _autoInitials() {
    if (_initialsCtrl.text.trim().isEmpty && _nameCtrl.text.trim().isNotEmpty) {
      _initialsCtrl.text = initialsFrom(_nameCtrl.text);
    }
  }

  Future<void> _save() async {
    _autoInitials();
    final draft = WomanDraft(
      name: _nameCtrl.text,
      initials: _initialsCtrl.text,
      emoji: _emoji,
      color: _color,
      privateNotes: _notesCtrl.text,
      tags: normalizeTags(_tags),
    );
    final errors = validateWomanDraft(draft);
    if (!errors.isValid) {
      setState(() => _errors = errors);
      return;
    }
    final notifier = ref.read(womenListProvider.notifier);
    if (isEditing) {
      await notifier.updateProfile(widget.profile!.woman.id, draft);
    } else {
      await notifier.create(draft);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar perfil' : 'Nuevo perfil'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar preview
              Center(
                child: GestureDetector(
                  onTap: _showEmojiPicker,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(_color).withValues(alpha: 0.2),
                    child: Text(_emoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _showEmojiPicker,
                  child: const Text('Cambiar emoji'),
                ),
              ),
              const SizedBox(height: 16),
              // Color picker
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profileColors.map((c) {
                  final selected = c == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  errorText: _errors.name,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_errors.name != null) {
                    setState(
                      () => _errors = WomanValidationErrors(
                        initials: _errors.initials,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              // Iniciales
              TextFormField(
                controller: _initialsCtrl,
                decoration: InputDecoration(
                  labelText: 'Iniciales *',
                  errorText: _errors.initials,
                  border: const OutlineInputBorder(),
                  helperText: 'Se generan automáticamente si las dejas vacías',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 4,
              ),
              const SizedBox(height: 12),
              // Notas
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas privadas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Etiquetas
              Text('Etiquetas', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...suggestedTags.map((tag) {
                    final selected = _tags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _tags.add(tag);
                          } else {
                            _tags.remove(tag);
                          }
                        });
                      },
                    );
                  }),
                  ActionChip(
                    label: const Text('+ Personalizada'),
                    onPressed: _addCustomTag,
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: _tags
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              // Guardar
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(isEditing ? Icons.save : Icons.person_add),
                label: Text(isEditing ? 'Guardar cambios' : 'Crear perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 250,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Elige un emoji',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: avatarEmojis.length,
                itemBuilder: (_, i) {
                  final e = avatarEmojis[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _emoji = e);
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      backgroundColor: _emoji == e
                          ? Color(_color).withValues(alpha: 0.3)
                          : null,
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCustomTag() {
    final ctrl = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva etiqueta'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la etiqueta'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Añadir'),
          ),
        ],
      ),
    ).then((value) {
      if (value != null && value.trim().isNotEmpty) {
        setState(() {
          final tag = value.trim();
          if (!_tags.contains(tag)) _tags.add(tag);
        });
      }
    });
  }
}
