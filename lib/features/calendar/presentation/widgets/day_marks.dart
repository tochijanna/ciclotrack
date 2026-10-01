import 'package:flutter/material.dart';

import '../../domain/day_mark.dart';

/// Glifo de una [DayMark]: la forma indica el estado, el color la mujer.
///
/// Lo usan tanto la cuadrícula como la leyenda para que no diverjan.
class MarkGlyph extends StatelessWidget {
  const MarkGlyph({super.key, required this.mark, this.size = 7});

  final DayMark mark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(mark.color);

    return switch (mark.kind) {
      DayMarkKind.menstruacion => _circle(context, color, filled: true),
      DayMarkKind.ventanaFertil => _circle(context, color, filled: false),
      DayMarkKind.ovulacion => _ovulation(context, color),
      DayMarkKind.encuentro => _glyph('⚡', color),
      DayMarkKind.ovulacionRegistrada => _glyph('♦', color),
      DayMarkKind.sintoma => _glyph('●', color),
    };
  }

  Widget _circle(BuildContext context, Color color, {required bool filled}) {
    final faded = _fade(color);
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      decoration: BoxDecoration(
        color: filled ? faded : Colors.transparent,
        border: filled ? null : Border.all(color: faded, width: 1.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _ovulation(BuildContext context, Color color) {
    final faded = _fade(color);
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      decoration: BoxDecoration(
        color: faded,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _glyph(String character, Color color) => Text(
    character,
    style: TextStyle(fontSize: size + 1, height: 1, color: _fade(color)),
  );

  /// Las proyecciones se atenúan para no confundirlas con datos registrados.
  Color _fade(Color color) =>
      mark.esEstimado ? color.withValues(alpha: 0.4) : color;
}

/// Marcas de un día dentro de una celda del calendario.
class DayMarks extends StatelessWidget {
  const DayMarks({super.key, required this.day, required this.marks});

  final DateTime day;
  final List<DayMark> marks;

  /// Cuántos glifos se dibujan antes de resumir el resto en «+N».
  static const maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    if (marks.isEmpty) return const SizedBox.shrink();

    final ordenados = [...marks]
      ..sort((a, b) => a.kind.index.compareTo(b.kind.index));
    final visibles = ordenados.take(maxVisible).toList();
    final restantes = ordenados.length - visibles.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final mark in visibles) MarkGlyph(mark: mark),
        if (restantes > 0)
          Text(
            '+$restantes',
            style: TextStyle(
              fontSize: 7,
              height: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
