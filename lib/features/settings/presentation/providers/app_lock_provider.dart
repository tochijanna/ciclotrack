import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_locale.dart';
import '../../../../core/time/clock.dart';

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

/// Tiempo en segundo plano a partir del cual se vuelve a pedir PIN o huella
/// (PRIV-01). Por debajo, volver a la app no interrumpe: da margen al selector
/// de archivos de la copia de seguridad.
const appLockGracePeriod = Duration(seconds: 60);

/// Resultado de intentar activar o desactivar el bloqueo de acceso.
enum AppLockChange {
  /// El cambio se guardó.
  saved,

  /// Desactivar exige autenticarse y la usuaria no lo consiguió o canceló.
  denied,

  /// No se pudo persistir el cambio.
  failed,
}

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

  /// Si la sesión está desbloqueada. Vuelve a `false` al regresar tras
  /// [appLockGracePeriod] en segundo plano.
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
  DateTime? _hiddenAt;

  @override
  AppLockState build() {
    final lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    ref.onDispose(() {
      _disposed = true;
      lifecycle.dispose();
    });
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

  // Solo cuenta el tiempo oculto de una sesión desbloqueada: así el diálogo de
  // autenticación del sistema, que también oculta la app, no re-bloquea
  // (PRIV-03).
  void _onHide() {
    if ((state.enabled || state.loadFailed) && state.unlocked) {
      _hiddenAt = ref.read(clockProvider).now();
    }
  }

  void _onShow() {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (hiddenAt == null) return;
    final away = ref.read(clockProvider).now().difference(hiddenAt);
    // Un reloj atrasado a mano da un tiempo negativo: también re-bloquea.
    if (away.isNegative || away >= appLockGracePeriod) {
      FocusManager.instance.primaryFocus?.unfocus();
      state = state.copyWith(unlocked: false);
    }
  }

  /// Activa o desactiva el bloqueo de acceso; el estado solo cambia con
  /// [AppLockChange.saved]. Quien lo activa ya está dentro de la app, así que
  /// la sesión en curso sigue desbloqueada. Desactivarlo exige PIN o huella:
  /// tener la app abierta en la mano no basta para quitar el bloqueo.
  Future<AppLockChange> setEnabled(bool value) async {
    if (!value && state.enabled && !await authenticate()) {
      return AppLockChange.denied;
    }
    var saved = false;
    try {
      final prefs = await ref.read(sharedPreferencesProvider)();
      saved = await prefs.setBool(appLockEnabledPrefKey, value);
    } catch (_) {
      saved = false;
    }
    if (saved && !_disposed) {
      // Lo recién escrito es el estado conocido: ya no hay fallo de lectura.
      state = state.copyWith(enabled: value, unlocked: true, loadFailed: false);
    }
    return saved ? AppLockChange.saved : AppLockChange.failed;
  }

  /// Pide PIN o huella y desbloquea la sesión si la usuaria se autentica.
  /// Cualquier error del plugin mantiene el cierre. Devuelve si se autenticó.
  Future<bool> authenticate() async {
    var ok = false;
    try {
      ok = await ref.read(localAuthProvider).authenticate();
    } catch (_) {
      ok = false;
    }
    if (ok && !_disposed) {
      state = state.copyWith(unlocked: true);
    }
    return ok;
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);
