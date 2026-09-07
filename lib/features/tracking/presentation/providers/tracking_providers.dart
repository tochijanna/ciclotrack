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

/// Provider familiar reactivo: emite el timeline de una mujer y se actualiza
/// automáticamente ante cualquier cambio en periodos, ovulación o síntomas.
final trackingTimelineProvider = StreamProvider.autoDispose
    .family<List<TrackingEvent>, int>((ref, womanId) {
      final repo = ref.watch(trackingRepositoryProvider);
      return repo.watchTimeline(womanId);
    });
