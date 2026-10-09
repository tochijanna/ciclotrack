import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
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

void main() {
  ProviderContainer makeContainer(
    FakeAppAuthenticator auth, {
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: [localAuthProvider.overrideWithValue(auth), ...overrides],
    );
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
    addTearDown(container.dispose);

    final notifier = await load(container);
    expect(notifier.state.ready, isTrue);
    expect(notifier.state.enabled, isFalse);
    expect(notifier.state.loadFailed, isFalse);
    expect(notifier.state.locked, isFalse);
  });

  test('setEnabled(true) persiste en SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer(FakeAppAuthenticator());
    addTearDown(container.dispose);

    final notifier = await load(container);

    expect(await notifier.setEnabled(true), isTrue);
    expect(notifier.state.enabled, isTrue);

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
      addTearDown(second.dispose);
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
    addTearDown(container.dispose);

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
    addTearDown(container.dispose);

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
    addTearDown(container.dispose);

    final notifier = await load(container);
    fail = true;
    expect(await notifier.setEnabled(true), isFalse);
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
    addTearDown(container.dispose);

    final notifier = await load(container);
    expect(await notifier.setEnabled(true), isFalse);
    expect(notifier.state.enabled, isFalse);
  });

  test('authenticate() con resultado true desbloquea', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final container = makeContainer(
      FakeAppAuthenticator(authenticateResult: true),
    );
    addTearDown(container.dispose);

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
    addTearDown(container.dispose);

    final notifier = await load(container);
    await notifier.authenticate();
    expect(notifier.state.locked, isTrue);
  });

  test('authenticate() que lanza mantiene el cierre', () async {
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});
    final container = makeContainer(
      FakeAppAuthenticator(throwOnAuthenticate: true),
    );
    addTearDown(container.dispose);

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

    final toggle = find.byType(SwitchListTile);
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
}
