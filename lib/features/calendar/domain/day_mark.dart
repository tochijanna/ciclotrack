/// Tipos de marca que puede llevar un día del calendario.
enum DayMarkKind {
  menstruacion,
  ventanaFertil,
  ovulacion,
  ovulacionRegistrada,
  sintoma,
  encuentro,
}

/// Marca de un día concreto para una mujer.
///
/// [color] es el ARGB del perfil; el dominio no depende de Flutter.
class DayMark {
  const DayMark({
    required this.womanId,
    required this.color,
    required this.kind,
    this.esEstimado = false,
  });

  final int womanId;
  final int color;
  final DayMarkKind kind;

  /// `true` cuando la marca es una proyección y no un registro real.
  final bool esEstimado;
}
