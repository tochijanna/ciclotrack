import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../../../core/l10n/app_locale.dart';
import '../../data/backup_file_gateway.dart';
import '../../data/backup_repository.dart';

final backupFileGatewayProvider = Provider<BackupFileGateway>(
  (ref) => const LocalBackupFileGateway(),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appLocalizationsProvider),
  ),
);
