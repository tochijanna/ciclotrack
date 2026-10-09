import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/time/clock.dart';
import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';

import '../../../support/fake_app_authenticator.dart';

class _Clock implements Clock {
  DateTime time = DateTime(2026, 10, 9, 12);

  @override
  DateTime now() => time;
}

void _lifecycle(List<AppLifecycleState> states) {
  for (final state in states) {
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(state);
  }
}

/// La app pasa a segundo plano (o queda tapada por un diálogo del sistema).
void _background() => _lifecycle(const [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
]);

void _foreground() => _lifecycle(const [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
]);

void main() {
  // `AppLifecycleListener` (creado al construir el notifier) requiere binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Clock clock;

  setUp(() {
    clock = _Clock();
    _lifecycle(const [AppLifecycleState.resumed]);
  });

  ProviderContainer makeContainer(FakeAppAuthenticator auth) {
    final container = ProviderContainer(
      overrides: [
        localAuthProvider.overrideWithValue(auth),
        clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Arranca con el bloqueo activado y la preferencia ya cargada.
  Future<AppLockController> enabledLock(ProviderContainer container) async {
    final notifier = container.read(appLockProvider.notifier);
    await pumpEventQueue();
    expect(notifier.state.enabled, isTrue);
    return notifier;
  }

  test('el estado por defecto deja el bloqueo desactivado', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());

    final notifier = container.read(appLockProvider.notifier);
    expect(notifier.state.enabled, isFalse);
    expect(notifier.state.unlocked, isFalse);
  });

  test('setEnabled(true) persiste y no bloquea la sesión en curso', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());

    final notifier = container.read(appLockProvider.notifier);
    // Deja terminar la carga asíncrona inicial para evitar sobrescrituras.
    await pumpEventQueue();

    await notifier.setEnabled(true);
    expect(notifier.state.enabled, isTrue);
    expect(notifier.state.unlocked, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(appLockEnabledPrefKey), isTrue);
  });

  test('authenticate() con resultado true pone unlocked=true', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: true),
    );

    final notifier = container.read(appLockProvider.notifier);
    await notifier.authenticate();
    expect(notifier.state.unlocked, isTrue);
  });

  test('authenticate() con resultado false no desbloquea', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: false),
    );

    final notifier = container.read(appLockProvider.notifier);
    await notifier.authenticate();
    expect(notifier.state.unlocked, isFalse);
  });

  group('PRIV-01: re-bloqueo tras segundo plano', () {
    setUp(
      () =>
          SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true}),
    );

    test('un arranque en frío siempre empieza bloqueado', () async {
      final notifier = await enabledLock(makeContainer(FakeAppAuthenticator()));
      expect(notifier.state.unlocked, isFalse);
    });

    test('menos de 60 s fuera no re-bloquea; 60 s sí', () async {
      final notifier = await enabledLock(makeContainer(FakeAppAuthenticator()));
      await notifier.authenticate();

      _background();
      clock.time = clock.time.add(const Duration(seconds: 59));
      _foreground();
      expect(notifier.state.unlocked, isTrue);

      _background();
      clock.time = clock.time.add(appLockGracePeriod);
      _foreground();
      expect(notifier.state.unlocked, isFalse);
    });

    test('un reloj atrasado mientras está fuera re-bloquea', () async {
      final notifier = await enabledLock(makeContainer(FakeAppAuthenticator()));
      await notifier.authenticate();

      _background();
      clock.time = clock.time.subtract(const Duration(hours: 1));
      _foreground();
      expect(notifier.state.unlocked, isFalse);
    });

    test('con el bloqueo desactivado no se bloquea nunca', () async {
      SharedPreferences.setMockInitialValues({});
      final container = makeContainer(FakeAppAuthenticator());
      final notifier = container.read(appLockProvider.notifier);
      await pumpEventQueue();
      await notifier.authenticate();

      _background();
      clock.time = clock.time.add(const Duration(hours: 1));
      _foreground();
      expect(notifier.state.unlocked, isTrue);
    });

    test(
      'PRIV-03: el diálogo de autenticación no cuenta como segundo plano',
      () async {
        final notifier = await enabledLock(
          makeContainer(FakeAppAuthenticator()),
        );

        // El diálogo del sistema oculta la app mientras la usuaria teclea.
        _background();
        clock.time = clock.time.add(const Duration(minutes: 5));
        await notifier.authenticate();
        _foreground();

        expect(notifier.state.unlocked, isTrue);
      },
    );
  });
}
