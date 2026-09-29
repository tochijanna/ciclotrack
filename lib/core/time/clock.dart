import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider del reloj de la aplicación. Permite inyectar un reloj falso en
/// tests para controlar el "hoy" sin depender de `DateTime.now()`.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
