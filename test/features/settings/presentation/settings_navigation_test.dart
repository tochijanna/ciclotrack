import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/alerts/presentation/providers/alerts_providers.dart';
import 'package:ciclotrack/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:ciclotrack/features/medications/presentation/screens/medications_screen.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
import 'package:ciclotrack/features/settings/presentation/providers/app_lock_provider.dart';
import 'package:ciclotrack/features/settings/presentation/screens/settings_screen.dart';

import '../../../support/fake_app_authenticator.dart';
import '../../../support/widget_harness.dart';

void main() {
  testWidgets('PRIV-07: seguridad aclara que el bloqueo no cifra', (
    tester,
  ) async {
    final db = createTestDatabase();
    await pumpScreen(
      tester,
      db,
      const SettingsScreen(),
      overrides: [localAuthProvider.overrideWithValue(FakeAppAuthenticator())],
    );
    await settleProviders(tester);

    expect(find.textContaining('tras 1 minuto en segundo plano'), findsOne);
    expect(find.textContaining('no cifra los datos'), findsOne);
    // Privado por defecto: los avisos discretos salen activados.
    await tester.scrollUntilVisible(find.text('Avisos discretos'), 200);
    final discretos = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Avisos discretos'),
    );
    expect(discretos.value, isTrue);

    await closeTestDatabase(tester, db);
  });

  testWidgets('ajustes abre la medicación real y permite volver', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');
    await pumpScreen(tester, db, const SettingsScreen());

    expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
    expect(find.text('Pastillas y horas de aviso, por mujer'), findsOneWidget);
    expect(find.text('Recordatorios'), findsNothing);
    await tester.tap(find.text('Medicación'));
    await settleProviders(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await settleProviders(tester);

    expect(find.byType(MedicationsScreen), findsOneWidget);
    expect(find.text('No hay medicamentos registrados'), findsOneWidget);
    expect(find.byTooltip('Añadir medicamento'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SettingsScreen), findsOneWidget);
    await closeTestDatabase(tester, db);
  });

  testWidgets('más opciones abre la pantalla real de alertas', (tester) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');
    await pumpScreen(
      tester,
      db,
      const WomenListScreen(),
      overrides: [
        fixedClock(DateTime(2026, 10, 1)),
        upcomingAlertsProvider.overrideWith((ref) async => []),
      ],
    );

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Alertas'));
    await settleProviders(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await settleProviders(tester);

    expect(find.byType(AlertsScreen), findsOneWidget);
    expect(find.text('Alertas activadas'), findsOneWidget);
    await closeTestDatabase(tester, db);
  });
}
