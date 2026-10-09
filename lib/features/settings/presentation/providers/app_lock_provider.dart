import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_locale.dart';

/// Interfaz fina sobre la autenticación local, para poder inyectar un fake en
/// tests sin depender del plugin real.
abstract class AppAuthenticator {
  Future<bool> isSupported();
  Future<bool> authenticate();
}

/// Implementación real con `local_auth` (PIN/huella del sistema).
class LocalAppAuthenticator implements AppAuthenticator {
  LocalAppAuthenticator({required String reason, LocalAuthentication? auth})
    : _reason = reason,
      _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  final String _reason;

  @override
  Future<bool> isSupported() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate() => _auth.authenticate(
    localizedReason: _reason,
    options: const AuthenticationOptions(biometricOnly: false),
  );
}

/// Proveedor de la autenticación local. Se inyecta un fake en tests.
final localAuthProvider = Provider<AppAuthenticator>((ref) {
  final l10n = ref.watch(appLocalizationsProvider);
  return LocalAppAuthenticator(reason: l10n.appLockAuthReason);
});

/// Acceso a `SharedPreferences`. Se sobrescribe en tests para simular fallos
/// de lectura o escritura.
final sharedPreferencesProvider =
    Provider<Future<SharedPreferences> Function()>(
      (ref) => SharedPreferences.getInstance,
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
    this.loadFailed = false,
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

  /// Si no se pudo leer la preferencia: no se sabe si el bloqueo está
  /// activado, así que se trata como bloqueado.
  final bool loadFailed;

  /// Si hay que cerrar el paso hasta que la usuaria se autentique.
  bool get locked => (enabled || loadFailed) && !unlocked;

  AppLockState copyWith({
    bool? enabled,
    bool? supported,
    bool? unlocked,
    bool? ready,
    bool? loadFailed,
  }) {
    return AppLockState(
      enabled: enabled ?? this.enabled,
      supported: supported ?? this.supported,
      unlocked: unlocked ?? this.unlocked,
      ready: ready ?? this.ready,
      loadFailed: loadFailed ?? this.loadFailed,
    );
  }
}

class AppLockController extends Notifier<AppLockState> {
  bool _disposed = false;

  @override
  AppLockState build() {
    ref.onDispose(() => _disposed = true);
    // La carga de preferencias y del soporte de autenticación es asíncrona;
    // mientras `ready` sea `false` la app no muestra contenido.
    Future.microtask(_load);
    return const AppLockState();
  }

  Future<void> _load() async {
    var enabled = false;
    var supported = false;
    var loadFailed = false;

    try {
      final prefs = await ref.read(sharedPreferencesProvider)();
      enabled = prefs.getBool(appLockEnabledPrefKey) ?? false;
    } catch (_) {
      // Estado desconocido: no equivale a «desactivado», se cierra el paso.
      loadFailed = true;
    }

    try {
      supported = await ref.read(localAuthProvider).isSupported();
    } catch (_) {
      supported = false;
    }

    if (_disposed) {
      return;
    }
    state = state.copyWith(
      enabled: enabled,
      supported: supported,
      ready: true,
      loadFailed: loadFailed,
    );
  }

  /// Reintenta la carga tras un fallo de lectura.
  Future<void> retry() => _load();

  /// Activa o desactiva el bloqueo de acceso. Devuelve `false`, sin cambiar
  /// el estado, si no se pudo persistir.
  Future<bool> setEnabled(bool value) async {
    var saved = false;
    try {
      final prefs = await ref.read(sharedPreferencesProvider)();
      saved = await prefs.setBool(appLockEnabledPrefKey, value);
    } catch (_) {
      saved = false;
    }
    if (saved && !_disposed) {
      // Lo recién escrito es el estado conocido: ya no hay fallo de lectura.
      state = state.copyWith(enabled: value, loadFailed: false);
    }
    return saved;
  }

  /// Pide PIN o huella y desbloquea la sesión si la usuaria se autentica.
  /// Cualquier error del plugin mantiene el cierre.
  Future<void> authenticate() async {
    var ok = false;
    try {
      ok = await ref.read(localAuthProvider).authenticate();
    } catch (_) {
      ok = false;
    }
    if (ok && !_disposed) {
      state = state.copyWith(unlocked: true);
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);
