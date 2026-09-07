import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../data/tracking_dao.dart';
import '../../data/tracking_repository.dart';
import '../../domain/tracking_event.dart';

// --- Providers base ---

final trackingDaoProvider = Provider<TrackingDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingDao(db);
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final dao = ref.watch(trackingDaoProvider);
  return TrackingRepository(dao);
});

// --- Timeline ---

/// Provider familiar que observa el timeline de una mujer concreta.
final trackingTimelineProvider =
    FutureProvider.family<List<TrackingEvent>, int>((ref, womanId) async {
      final repo = ref.watch(trackingRepositoryProvider);
      return repo.getTimelineOnce(womanId);
    });
