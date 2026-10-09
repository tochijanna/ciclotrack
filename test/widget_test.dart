import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/core/time/clock.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
import 'package:ciclotrack/features/settings/presentation/screens/app_lock_screen.dart';
import 'package:ciclotrack/features/settings/presentation/screens/settings_screen.dart';
import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';
import 'package:ciclotrack/main.dart';

import 'support/fake_app_authenticator.dart';
import 'support/widget_harness.dart';

class _Clock implements Clock {
  DateTime time = DateTime(2026, 10, 9, 12);

  @override
  DateTime now() => time;
}

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          localAuthProvider.overrideWithValue(FakeAppAuthenticator()),
        ],
        child: const CicloTrackApp(),
      ),
    );

    // Allow initial providers without waiting for long-lived alert streams.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('CicloTrack'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });

  testWidgets('PRIV-02: el re-bloqueo tapa la ruta abierta y la conserva', (
    tester,
  ) async {
    final db = createTestDatabase();
    final clock = _Clock();
    SharedPreferences.setMockInitialValues({appLockEnabledPrefKey: true});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          localAuthProvider.overrideWithValue(FakeAppAuthenticator()),
          clockProvider.overrideWithValue(clock),
        ],
        child: const CicloTrackApp(),
      ),
    );
    await settleProviders(tester);

    // Arranque en frío: bloqueada y sin contenido a la vista.
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.byType(WomenListScreen), findsNothing);

    await tester.tap(find.byIcon(Icons.lock_open));
    await settleProviders(tester);
    expect(find.byType(AppLockScreen), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settleProviders(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SettingsScreen), findsOneWidget);

    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    clock.time = clock.time.add(appLockGracePeriod);
    for (final state in const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settleProviders(tester);

    // La ruta que estaba abierta queda tapada, también para TalkBack.
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Avisos discretos')), findsNothing);

    await tester.tap(find.byIcon(Icons.lock_open));
    await settleProviders(tester);
    expect(find.byType(AppLockScreen), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
