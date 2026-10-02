import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';

import '../../../support/fake_app_authenticator.dart';

void main() {
  ProviderContainer makeContainer(FakeAppAuthenticator auth) {
    return ProviderContainer(
      overrides: [localAuthProvider.overrideWithValue(auth)],
    );
  }

  test('el estado por defecto deja el bloqueo desactivado', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());
    addTearDown(container.dispose);

    final notifier = container.read(appLockProvider.notifier);
    expect(notifier.state.enabled, isFalse);
    expect(notifier.state.unlocked, isFalse);
  });

  test('setEnabled(true) persiste en SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());
    addTearDown(container.dispose);

    final notifier = container.read(appLockProvider.notifier);
    // Deja terminar la carga asíncrona inicial para evitar sobrescrituras.
    await pumpEventQueue();

    await notifier.setEnabled(true);
    expect(notifier.state.enabled, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(appLockEnabledPrefKey), isTrue);
  });

  test('authenticate() con resultado true pone unlocked=true', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: true),
    );
    addTearDown(container.dispose);

    final notifier = container.read(appLockProvider.notifier);
    await notifier.authenticate();
    expect(notifier.state.unlocked, isTrue);
  });

  test('authenticate() con resultado false no desbloquea', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: false),
    );
    addTearDown(container.dispose);

    final notifier = container.read(appLockProvider.notifier);
    await notifier.authenticate();
    expect(notifier.state.unlocked, isFalse);
  });
}
