import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Locales soportados por la aplicación. El orden importa: `es` va primero
/// para que sea el fallback cuando el idioma del sistema no está soportado.
const supportedAppLocales = <Locale>[Locale('es'), Locale('en')];

/// Resuelve el locale de la aplicación a partir de las preferencias del
/// sistema: `es` o `en`, con `es` como fallback.
Locale resolveAppLocale(List<Locale> preferred) {
  for (final locale in preferred) {
    final code = locale.languageCode;
    if (code == 'es' || code == 'en') return Locale(code);
  }
  return const Locale('es');
}

/// Locale resuelto de la aplicación, disponible para flujos sin `BuildContext`
/// (notificaciones, recordatorios, PDF/CSV de copia de seguridad).
final appLocaleProvider = Provider<Locale>(
  (ref) => resolveAppLocale(WidgetsBinding.instance.platformDispatcher.locales),
);

/// Instancia de [AppLocalizations] para el locale resuelto.
final appLocalizationsProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(appLocaleProvider)),
);
