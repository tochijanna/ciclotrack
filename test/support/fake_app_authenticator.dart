import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';

/// Fake de [AppAuthenticator] para tests, con resultados configurables y sin
/// tocar el plugin real de `local_auth` (inexistente en el entorno de test).
class FakeAppAuthenticator implements AppAuthenticator {
  FakeAppAuthenticator({this.supported = true, this.authenticateResult = true});

  final bool supported;
  final bool authenticateResult;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> authenticate() async => authenticateResult;
}
