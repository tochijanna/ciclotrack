import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';

/// Fake de [AppAuthenticator] para tests, con resultados configurables y sin
/// tocar el plugin real de `local_auth` (inexistente en el entorno de test).
class FakeAppAuthenticator implements AppAuthenticator {
  FakeAppAuthenticator({
    this.supported = true,
    this.authenticateResult = true,
    this.throwOnAuthenticate = false,
  });

  final bool supported;
  final bool authenticateResult;

  /// Simula un error del plugin (sin PIN configurado, demasiados intentos…).
  final bool throwOnAuthenticate;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> authenticate() async {
    if (throwOnAuthenticate) {
      throw Exception('local_auth no disponible');
    }
    return authenticateResult;
  }
}
