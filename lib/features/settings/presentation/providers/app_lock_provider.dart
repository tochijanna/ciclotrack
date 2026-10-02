import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interfaz fina sobre la autenticación local, para poder inyectar un fake en
/// tests sin depender del plugin real.
abstract class AppAuthenticator {
  Future<bool> isSupported();
  Future<bool> authenticate();
}

/// Implementación real con `local_auth` (PIN/huella del sistema).
class LocalAppAuthenticator implements AppAuthenticator {
  LocalAppAuthenticator([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isSupported() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate() => _auth.authenticate(
    localizedReason: 'Desbloquea CicloTrack para continuar',
    options: const AuthenticationOptions(biometricOnly: false),
  );
}

/// Proveedor de la autenticación local. Se inyecta un fake en tests.
final localAuthProvider = Provider<AppAuthenticator>(
  (_) => LocalAppAuthenticator(),
);

/// Clave en `SharedPreferences` que guarda si el bloqueo de acceso está
/// activado.
const appLockEnabledPrefKey = 'app_lock_enabled';

class AppLockState {
  const AppLockState({
    this.enabled = false,
    this.supported = false,
    this.unlocked = false,
    this.ready = false,
  });

  /// Si el bloqueo de acceso está activado por la usuaria.
  final bool enabled;

  /// Si el dispositivo soporta autenticación local (PIN/huella).
  final bool supported;

  /// Si la sesión ya se desbloqueó (tras autenticarse una vez).
  final bool unlocked;

  /// Si ya terminó de cargar la preferencia y el soporte del dispositivo.
  /// Mientras sea `false` no debe mostrarse contenido sensible.
  final bool ready;

  AppLockState copyWith({
    bool? enabled,
    bool? supported,
    bool? unlocked,
    bool? ready,
  }) {
    return AppLockState(
      enabled: enabled ?? this.enabled,
      supported: supported ?? this.supported,
      unlocked: unlocked ?? this.unlocked,
      ready: ready ?? this.ready,
    );
  }
}

class AppLockController extends Notifier<AppLockState> {
  bool _disposed = false;

  @override
  AppLockState build() {
    ref.onDispose(() => _disposed = true);
    // La carga de preferencias y del soporte de autenticación es asíncrona;
    // mientras tanto el estado por defecto deja la app sin bloqueo.
    Future.microtask(_load);
    return const AppLockState();
  }

  Future<void> _load() async {
    var enabled = false;
    var supported = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(appLockEnabledPrefKey) ?? false;
    } catch (_) {
      // Sin preferencias disponibles (p. ej. en tests) se mantiene apagado.
      enabled = false;
    }

    try {
      supported = await ref.read(localAuthProvider).isSupported();
    } catch (_) {
      supported = false;
    }

    if (_disposed) {
      return;
    }
    state = state.copyWith(enabled: enabled, supported: supported, ready: true);
  }

  /// Activa o desactiva el bloqueo de acceso y lo persiste.
  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(appLockEnabledPrefKey, value);
    } catch (_) {
      // Sin persistencia no se guarda; el estado en memoria prevalece.
    }
  }

  /// Marca la sesión como desbloqueada sin pasar por la autenticación.
  void unlock() {
    state = state.copyWith(unlocked: true);
  }

  /// Pide PIN o huella y desbloquea la sesión si la usuaria se autentica.
  Future<void> authenticate() async {
    final ok = await ref.read(localAuthProvider).authenticate();
    if (ok) {
      state = state.copyWith(unlocked: true);
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);
