import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';
import 'package:ciclotrack/main.dart';

import 'support/fake_app_authenticator.dart';

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
}
