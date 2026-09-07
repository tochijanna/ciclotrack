/// Modelo inmutable para crear/editar un perfil de mujer.
class WomanDraft {
  const WomanDraft({
    required this.name,
    required this.initials,
    this.emoji = '👩',
    this.color = 0xFFE91E63,
    this.privateNotes = '',
    this.tags = const [],
    this.sortOrder = 0,
  });

  final String name;
  final String initials;
  final String emoji;
  final int color;
  final String privateNotes;
  final List<String> tags;
  final int sortOrder;

  WomanDraft copyWith({
    String? name,
    String? initials,
    String? emoji,
    int? color,
    String? privateNotes,
    List<String>? tags,
    int? sortOrder,
  }) {
    return WomanDraft(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      privateNotes: privateNotes ?? this.privateNotes,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
