import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';

/// Pantalla que bloquea el acceso hasta que la usuaria se autentica con su
/// PIN o huella. Solo se muestra cuando el bloqueo está activado y la sesión
/// aún no se ha desbloqueado.
class AppLockScreen extends ConsumerWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                l10n.appLockedTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.appLockedSubtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(appLockProvider.notifier).authenticate(),
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.appUnlock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
