import 'cycle_phase.dart';

/// Pronóstico de humor/libido para una fase del ciclo.
class MoodForecast {
  const MoodForecast({
    required this.fase,
    required this.humor,
    required this.libido,
    this.consejo,
  });

  final CyclePhase fase;
  final String humor;
  final String libido;
  final String? consejo;
}

/// Mapa estático fase → pronóstico de humor/libido.
const Map<CyclePhase, MoodForecast> moodByPhase = {
  CyclePhase.menstruacion: MoodForecast(
    fase: CyclePhase.menstruacion,
    humor: 'Bajo / cansancio',
    libido: 'Baja',
    consejo: 'Déjala tranquila',
  ),
  CyclePhase.follicular: MoodForecast(
    fase: CyclePhase.follicular,
    humor: 'Buen humor',
    libido: 'En aumento',
    consejo: 'Buen momento para planes',
  ),
  CyclePhase.ventanaFertil: MoodForecast(
    fase: CyclePhase.ventanaFertil,
    humor: 'Bueno',
    libido: 'Alta',
    consejo: 'Días de riesgo',
  ),
  CyclePhase.ovulacion: MoodForecast(
    fase: CyclePhase.ovulacion,
    humor: 'Muy bueno',
    libido: 'Cachonda (pico)',
    consejo: 'Riesgo máximo',
  ),
  CyclePhase.lutea: MoodForecast(
    fase: CyclePhase.lutea,
    humor: 'Variable',
    libido: 'En descenso',
  ),
  CyclePhase.luteaTardia: MoodForecast(
    fase: CyclePhase.luteaTardia,
    humor: 'Irritable / mal humor',
    libido: 'Variable',
    consejo: 'Paciencia, mejor no discutir',
  ),
  CyclePhase.retraso: MoodForecast(
    fase: CyclePhase.retraso,
    humor: 'Imprevisible',
    libido: '—',
    consejo: 'Posible retraso, comprueba registro',
  ),
};

/// Nombre legible de la fase en español.
String nombreFase(CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruacion:
      return 'Menstruación';
    case CyclePhase.follicular:
      return 'Folicular';
    case CyclePhase.ventanaFertil:
      return 'Ventana fértil';
    case CyclePhase.ovulacion:
      return 'Ovulación';
    case CyclePhase.lutea:
      return 'Lútea';
    case CyclePhase.luteaTardia:
      return 'Lútea tardía (PMS)';
    case CyclePhase.retraso:
      return 'Retraso';
  }
}
