import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../calendar/presentation/screens/calendar_home_screen.dart';
import '../../../encounters/presentation/screens/encounter_form_screen.dart';
import '../../../encounters/presentation/screens/encounters_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tracking/presentation/screens/tracking_screen.dart';
import '../../data/women_repository.dart';
import '../l10n.dart';
import '../providers/women_providers.dart';
import '../widgets/woman_card.dart';
import 'woman_form_screen.dart';

enum _MenuAction { views, reports, backup, alerts, refresh }

class WomenListScreen extends ConsumerWidget {
  const WomenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profilesAsync = ref.watch(womenListProvider);
    final filter = ref.watch(womenFilterProvider);
    final tagsAsync = ref.watch(availableTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CicloTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.menuSettings,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: l10n.menuMoreOptions,
            onSelected: (action) => _onMenuAction(context, ref, action),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.views,
                child: Text(l10n.menuViews),
              ),
              PopupMenuItem(
                value: _MenuAction.reports,
                child: Text(l10n.menuReports),
              ),
              PopupMenuItem(
                value: _MenuAction.backup,
                child: Text(l10n.menuBackup),
              ),
              PopupMenuItem(
                value: _MenuAction.alerts,
                child: Text(l10n.menuAlerts),
              ),
              PopupMenuItem(
                value: _MenuAction.refresh,
                child: Text(l10n.menuRefresh),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por etiquetas
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(l10n.filterAll),
                        selected: filter == null,
                        onSelected: (_) =>
                            ref.read(womenFilterProvider.notifier).clear(),
                      ),
                    ),
                    ...tags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(suggestedTagLabel(l10n, tag)),
                          selected: filter == tag,
                          onSelected: (_) => ref
                              .read(womenFilterProvider.notifier)
                              .setFilter(tag),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Lista de perfiles
          Expanded(
            child: profilesAsync.when(
              data: (profiles) {
                if (profiles.isEmpty) {
                  return EmptyWomenView(
                    onAdd: () => _navigateToForm(context, ref),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(womenListProvider.notifier).refresh(),
                  child: _buildProfilesList(
                    context,
                    ref,
                    profiles,
                    reorderable: filter == null,
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorLabel}: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addNew),
      ),
    );
  }

  void _onMenuAction(BuildContext context, WidgetRef ref, _MenuAction action) {
    final Widget screen;
    switch (action) {
      case _MenuAction.views:
        screen = const CalendarHomeScreen();
      case _MenuAction.reports:
        screen = const ReportsScreen();
      case _MenuAction.backup:
        screen = const BackupScreen();
      case _MenuAction.alerts:
        screen = const AlertsScreen();
      case _MenuAction.refresh:
        ref.read(womenListProvider.notifier).refresh();
        return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.newProfile),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToForm(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(l10n.newEncounter),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EncounterFormScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: Text(l10n.viewEncounters),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EncountersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesList(
    BuildContext context,
    WidgetRef ref,
    List<WomanProfile> profiles, {
    required bool reorderable,
  }) {
    Widget itemBuilder(BuildContext context, int index) {
      final profile = profiles[index];
      return WomanCard(
        key: ValueKey(profile.woman.id),
        profile: profile,
        onTap: () => _navigateToTracking(context, profile),
        onEdit: () => _navigateToForm(context, ref, profile: profile),
        onLongPress: () => _confirmDelete(context, ref, profile),
      );
    }

    if (!reorderable) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: profiles.length,
        itemBuilder: itemBuilder,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: profiles.length,
      onReorderItem: (oldIndex, newIndex) {
        // onReorderItem entrega newIndex ya ajustado (sin decrementar).
        final ordered = profiles.map((p) => p.woman).toList();
        final item = ordered.removeAt(oldIndex);
        ordered.insert(newIndex, item);
        ref.read(womenListProvider.notifier).reorder(ordered);
      },
      itemBuilder: itemBuilder,
    );
  }

  void _navigateToForm(
    BuildContext context,
    WidgetRef ref, {
    WomanProfile? profile,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WomanFormScreen(profile: profile)),
    );
  }

  void _navigateToTracking(BuildContext context, WomanProfile profile) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrackingScreen(profile: profile)));
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WomanProfile profile,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProfileTitle),
        content: Text(l10n.deleteProfileBody(profile.woman.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(womenListProvider.notifier).deleteProfile(profile.woman.id);
      }
    });
  }
}
