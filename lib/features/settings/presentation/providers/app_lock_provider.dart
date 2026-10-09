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

/// Clave en `SharedPreferences` que guarda si el bloqueo de acceso está
/// activado.
const appLockEnabledPrefKey = 'app_lock_enabled';

/// Tiempo en segundo plano a partir del cual se vuelve a pedir PIN o huella
/// (PRIV-01). Por debajo, volver a la app no interrumpe: da margen al selector
/// de archivos de la copia de seguridad.
const appLockGracePeriod = Duration(seconds: 60);

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

  /// Si la sesión está desbloqueada. Vuelve a `false` al regresar tras
  /// [appLockGracePeriod] en segundo plano.
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
  DateTime? _hiddenAt;

  @override
  AppLockState build() {
    final lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    ref.onDispose(() {
      _disposed = true;
      lifecycle.dispose();
    });
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

  // Solo cuenta el tiempo oculto de una sesión desbloqueada: así el diálogo de
  // autenticación del sistema, que también oculta la app, no re-bloquea
  // (PRIV-03).
  void _onHide() {
    if (state.enabled && state.unlocked) {
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

  /// Activa o desactiva el bloqueo de acceso y lo persiste. Quien lo activa
  /// ya está dentro de la app, así que la sesión en curso sigue desbloqueada.
  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value, unlocked: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(appLockEnabledPrefKey, value);
    } catch (_) {
      // Sin persistencia no se guarda; el estado en memoria prevalece.
    }
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
