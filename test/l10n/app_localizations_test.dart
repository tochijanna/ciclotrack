import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/l10n/app_locale.dart';
import 'package:ciclotrack/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('carga español e inglés por lookup', () {
      final es = lookupAppLocalizations(const Locale('es'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(es.localeName, 'es');
      expect(en.localeName, 'en');
      expect(es.menuSettings, 'Ajustes');
      expect(en.menuSettings, 'Settings');
      expect(es.alertsTitle, 'Alertas');
      expect(en.alertsTitle, 'Alerts');
    });

    test('los placeholders se interpolan', () {
      final es = lookupAppLocalizations(const Locale('es'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(
        es.deleteProfileBody('María'),
        '¿Eliminar a María? Se borrarán todos sus datos.',
      );
      expect(
        en.deleteProfileBody('María'),
        'Delete María? All their data will be deleted.',
      );
      expect(es.flowLevel(3), 'Flujo: 3/5');
      expect(en.flowLevel(3), 'Flow: 3/5');
    });

    test('los plurales distinguen singular y plural', () {
      final es = lookupAppLocalizations(const Locale('es'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(es.daysCount(1), '1 día');
      expect(es.daysCount(5), '5 días');
      expect(en.daysCount(1), '1 day');
      expect(en.daysCount(5), '5 days');
    });

    test('supportedLocales incluye es y en', () {
      expect(supportedAppLocales, const [Locale('es'), Locale('en')]);
    });
  });

  group('resolveAppLocale', () {
    test('español como fallback y por preferencia', () {
      expect(resolveAppLocale(const [Locale('es')]), const Locale('es'));
      expect(resolveAppLocale(const [Locale('en')]), const Locale('en'));
      expect(resolveAppLocale(const [Locale('fr')]), const Locale('es'));
      expect(resolveAppLocale(const []), const Locale('es'));
      expect(
        resolveAppLocale(const [Locale('fr'), Locale('en')]),
        const Locale('en'),
      );
    });
  });

  group('renderizado por locale', () {
    Widget probe() => Builder(
      builder: (context) => Text(AppLocalizations.of(context).menuViews),
    );

    testWidgets('español', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: Scaffold(body: probe()),
        ),
      );
      expect(find.text('Vistas'), findsOneWidget);
    });

    testWidgets('inglés', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: Scaffold(body: probe()),
        ),
      );
      expect(find.text('Views'), findsOneWidget);
    });
  });
}
