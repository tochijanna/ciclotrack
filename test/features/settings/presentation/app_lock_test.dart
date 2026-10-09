import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
import 'package:ciclotrack/core/time/clock.dart';
import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';
import 'package:ciclotrack/features/settings/presentation/screens/app_lock_screen.dart';
import 'package:ciclotrack/features/settings/presentation/screens/settings_screen.dart';
import 'package:ciclotrack/main.dart';

import '../../../support/fake_app_authenticator.dart';
import '../../../support/widget_harness.dart';

/// Preferencias cuya escritura no llega a disco: `setBool` devuelve `false`.
class _UnwritablePrefs extends Fake implements SharedPreferences {
  @override
  bool? getBool(String key) => null;

  @override
  Future<bool> setBool(String key, bool value) async => false;
}

Override _brokenPrefs() => sharedPreferencesProvider.overrideWithValue(
  () async => throw Exception('preferencias no disponibles'),
);

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

  ProviderContainer makeContainer(
    FakeAppAuthenticator auth, {
    List<Override> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        localAuthProvider.overrideWithValue(auth),
        clockProvider.overrideWithValue(clock),
        ...overrides,
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

  /// Lee el provider y deja terminar la carga asíncrona inicial.
  Future<AppLockController> load(ProviderContainer container) async {
    final notifier = container.read(appLockProvider.notifier);
    await pumpEventQueue();
    return notifier;
  }

  test('el estado por defecto deja el bloqueo desactivado', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());

    final notifier = await load(container);
    expect(notifier.state.ready, isTrue);
    expect(notifier.state.enabled, isFalse);
    expect(notifier.state.loadFailed, isFalse);
    expect(notifier.state.locked, isFalse);
  });

  test('setEnabled(true) persiste y no bloquea la sesión en curso', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());

    final notifier = await load(container);

    expect(await notifier.setEnabled(true), AppLockChange.saved);
    expect(notifier.state.enabled, isTrue);
    expect(notifier.state.unlocked, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(appLockEnabledPrefKey), isTrue);
  });

  test(
    'tras reiniciar, el bloqueo activado vuelve a exigir autenticación',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = makeContainer(FakeAppAuthenticator());
      final notifier = await load(first);
      await notifier.setEnabled(true);
      await notifier.authenticate();
      expect(notifier.state.locked, isFalse);
      first.dispose();

      final second = makeContainer(FakeAppAuthenticator());
      final restarted = await load(second);
      expect(restarted.state.enabled, isTrue);
      expect(restarted.state.unlocked, isFalse);
      expect(restarted.state.locked, isTrue);
    },
  );

  test('una lectura fallida deja el estado desconocido y bloqueado', () async {
    final container = makeContainer(
      FakeAppAuthenticator(),
      overrides: [_brokenPrefs()],
    );

    final notifier = await load(container);
    expect(notifier.state.ready, isTrue);
    expect(notifier.state.loadFailed, isTrue);
    expect(notifier.state.locked, isTrue);
  });

  test('retry() recupera el estado real tras un fallo transitorio', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: false});
    var fail = true;
    final container = makeContainer(
      FakeAppAuthenticator(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          () async => fail
              ? throw Exception('fallo transitorio')
              : SharedPreferences.getInstance(),
        ),
      ],
    );

    final notifier = await load(container);
    expect(notifier.state.locked, isTrue);

    fail = false;
    await notifier.retry();
    expect(notifier.state.loadFailed, isFalse);
    expect(notifier.state.locked, isFalse);
  });

  test('una escritura que lanza no cambia el estado', () async {
    SharedPreferences.setMockInitialValues({});
    var fail = false;
    final container = makeContainer(
      FakeAppAuthenticator(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          () async => fail
              ? throw Exception('sin almacenamiento')
              : SharedPreferences.getInstance(),
        ),
      ],
    );

    final notifier = await load(container);
    fail = true;
    expect(await notifier.setEnabled(true), AppLockChange.failed);
    expect(notifier.state.enabled, isFalse);
  });

  test('una escritura que devuelve false no cambia el estado', () async {
    final container = makeContainer(
      FakeAppAuthenticator(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          () async => _UnwritablePrefs(),
        ),
      ],
    );

    final notifier = await load(container);
    expect(await notifier.setEnabled(true), AppLockChange.failed);
    expect(notifier.state.enabled, isFalse);
  });

  test('desactivar el bloqueo exige autenticarse', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final denied = await load(
      makeContainer(FakeAppAuthenticator(authenticateResult: false)),
    );
    expect(await denied.setEnabled(false), AppLockChange.denied);
    expect(denied.state.enabled, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(appLockEnabledPrefKey), isTrue);

    final thrown = await load(
      makeContainer(FakeAppAuthenticator(throwOnAuthenticate: true)),
    );
    expect(await thrown.setEnabled(false), AppLockChange.denied);
    expect(thrown.state.enabled, isTrue);

    final allowed = await load(makeContainer(FakeAppAuthenticator()));
    expect(await allowed.setEnabled(false), AppLockChange.saved);
    expect(allowed.state.enabled, isFalse);
    expect(prefs.getBool(appLockEnabledPrefKey), isFalse);
  });

  test('authenticate() con resultado true desbloquea', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: true),
    );

    final notifier = await load(container);
    expect(notifier.state.locked, isTrue);
    await notifier.authenticate();
    expect(notifier.state.locked, isFalse);
  });

  test('authenticate() con resultado false mantiene el cierre', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: false),
    );

    final notifier = await load(container);
    await notifier.authenticate();
    expect(notifier.state.locked, isTrue);
  });

  test('authenticate() que lanza mantiene el cierre', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final container = makeContainer(
      FakeAppAuthenticator(throwOnAuthenticate: true),
    );

    final notifier = await load(container);
    await notifier.authenticate();
    expect(notifier.state.locked, isTrue);
  });

  testWidgets('con lectura fallida la app no muestra contenido', (
    tester,
  ) async {
    final db = createTestDatabase();
    // App completa: como en widget_test.dart, solo `pump` (sin `runAsync`)
    // para no arrancar los streams de drift de los coordinadores, y la base
    // se cierra al desmontar el árbol.
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          localAuthProvider.overrideWithValue(
            FakeAppAuthenticator(authenticateResult: false),
          ),
          _brokenPrefs(),
        ],
        child: const CicloTrackApp(),
      ),
    );
    await pumpStreams(tester);

    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.byType(WomenListScreen), findsNothing);
    // El aviso de error ofrece reintentar además de desbloquear.
    expect(find.byType(TextButton), findsOneWidget);

    // Autenticación fallida: sigue cerrado.
    await tester.tap(find.byType(FilledButton));
    await pumpStreams(tester);
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.byType(WomenListScreen), findsNothing);
  });

  testWidgets('ajustes no desactiva el bloqueo sin autenticación', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final db = createTestDatabase();
    await pumpScreen(
      tester,
      db,
      const SettingsScreen(),
      overrides: [
        localAuthProvider.overrideWithValue(
          FakeAppAuthenticator(authenticateResult: false),
        ),
      ],
    );

    final toggle = find.widgetWithIcon(SwitchListTile, Icons.fingerprint);
    await tester.scrollUntilVisible(toggle, 200);
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    await tester.tap(toggle);
    await settleProviders(tester);

    expect(
      find.text(
        'El bloqueo sigue activado: hay que desbloquear con PIN o huella '
        'para desactivarlo.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

    await closeTestDatabase(tester, db);
  });

  testWidgets('ajustes avisa si no se pudo guardar el bloqueo', (tester) async {
    final db = createTestDatabase();
    await pumpScreen(
      tester,
      db,
      const SettingsScreen(),
      overrides: [
        localAuthProvider.overrideWithValue(FakeAppAuthenticator()),
        sharedPreferencesProvider.overrideWithValue(
          () async => _UnwritablePrefs(),
        ),
      ],
    );

    final toggle = find.widgetWithIcon(SwitchListTile, Icons.fingerprint);
    await tester.scrollUntilVisible(toggle, 200);
    await tester.tap(toggle);
    await settleProviders(tester);

    expect(
      find.text('No se pudo guardar el bloqueo de acceso. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    await closeTestDatabase(tester, db);
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

    test('con lectura fallida también re-bloquea tras 60 s fuera', () async {
      final notifier = await load(
        makeContainer(FakeAppAuthenticator(), overrides: [_brokenPrefs()]),
      );
      await notifier.authenticate();
      expect(notifier.state.locked, isFalse);

      _background();
      clock.time = clock.time.add(appLockGracePeriod);
      _foreground();
      expect(notifier.state.locked, isTrue);
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
