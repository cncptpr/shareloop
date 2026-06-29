import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/components/item_widget.dart';
import 'package:shareloop/screens/create_item_screen.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/state/item_form.dart';
import 'package:shareloop/state/item_search.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart';
import 'package:shareloop/state/location_search.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _locationLabel(WidgetRef ref) {
    final selected = ref.watch(selectedLocationProvider);
    String formatLabel(SearchedLocation l) {
      final parts = [l.postalCode, l.city]..removeWhere((s) => s.isEmpty);
      return parts.isEmpty ? l.name : parts.join(' ');
    }
    switch (selected) {
      case SearchedLocation manual:
        return formatLabel(manual);
      case GPSLocation _:
        final gps = ref.watch(currentPositionProvider).asData?.value;
        if (gps == null) return 'Position wählen';
        final reverse = ref.watch(
          reverseLocationProvider((gps.latitude, gps.longitude)),
        );
        return reverse.when(
          data: (loc) => loc != null ? formatLabel(loc) : 'Aktuelle Position',
          loading: () => 'Aktuelle Position',
          error: (_, __) => 'Aktuelle Position',
        );
      default:
        return 'Position wählen';
    }
  }

  Future<void> _openLocationPicker() async {
    final current = ref.read(selectedLocationProvider);
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: current),
      ),
    );
    if (result != null && mounted) {
      ref.read(selectedLocationProvider.notifier).select(result);
    } else if (mounted) {
      ref.read(selectedLocationProvider.notifier).clear();
    }
  }

  bool _hasActiveFilters(SearchFilters f) {
    return f.query.isNotEmpty ||
        f.categories.isNotEmpty ||
        f.maxDistanceKm != null ||
        f.minScore != null;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchFiltersProvider.notifier).setQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = _locationLabel(ref);
    final filters = ref.watch(searchFiltersProvider);
    final hasFilters = _hasActiveFilters(filters);

    final itemsAsync = hasFilters
        ? ref.watch(searchItemsProvider)
        : ref.watch(featuredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Screen'),
        actions: [
          TextButton.icon(
            onPressed: _openLocationPicker,
            icon: const Icon(Icons.location_on),
            label: Text(label),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateItemScreen.push(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SearchBar(
            hintText: "Suche für Inserate",
            controller: _searchController,
          ),
          if (itemsAsync.isLoading || itemsAsync.isReloading)
            const LinearProgressIndicator(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                ActionChip(
                  label: Text(
                    filters.categories.isEmpty
                        ? 'Kategorien'
                        : 'Kategorien (${filters.categories.length})',
                  ),
                  avatar: const Icon(Icons.category, size: 16),
                  onPressed: () => _showCategoryDialog(context),
                ),
                const SizedBox(width: 4),
                _ActiveFilterChip(
                  active: filters.maxDistanceKm != null,
                  label: filters.maxDistanceKm != null
                      ? '≤${filters.maxDistanceKm!.toInt()} km'
                      : 'Entfernung',
                  icon: Icons.explore,
                  onClear: filters.maxDistanceKm != null
                      ? () => ref.read(searchFiltersProvider.notifier).setMaxDistanceKm(null)
                      : null,
                  childBuilder: () => PopupMenuButton<double>(
                    onSelected: (v) {
                      ref.read(searchFiltersProvider.notifier).setMaxDistanceKm(v);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 1, child: Text('1 km')),
                      const PopupMenuItem(value: 5, child: Text('5 km')),
                      const PopupMenuItem(value: 10, child: Text('10 km')),
                      const PopupMenuItem(value: 25, child: Text('25 km')),
                      const PopupMenuItem(value: 50, child: Text('50 km')),
                    ],
                    child: const Chip(
                      label: Text('Entfernung'),
                      avatar: Icon(Icons.explore, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _ActiveFilterChip(
                  active: filters.minScore != null,
                  label: filters.minScore != null
                      ? '≥${filters.minScore}★'
                      : 'Mindestbewertung',
                  icon: Icons.star,
                  onClear: filters.minScore != null
                      ? () => ref.read(searchFiltersProvider.notifier).setMinScore(null)
                      : null,
                  childBuilder: () => PopupMenuButton<double>(
                    onSelected: (v) {
                      ref.read(searchFiltersProvider.notifier).setMinScore(v);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 3, child: Text('3★ und mehr')),
                      const PopupMenuItem(value: 3.5, child: Text('3.5★ und mehr')),
                      const PopupMenuItem(value: 4, child: Text('4★ und mehr')),
                      const PopupMenuItem(value: 4.5, child: Text('4.5★ und mehr')),
                    ],
                    child: const Chip(
                      label: Text('Mindestbewertung'),
                      avatar: Icon(Icons.star, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<ItemSearchRequestSortByEnum>(
                  onSelected: (v) {
                    ref.read(searchFiltersProvider.notifier).setSortBy(v);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: ItemSearchRequestSortByEnum.relevance, child: Text('Beste Treffer')),
                    const PopupMenuItem(value: ItemSearchRequestSortByEnum.score, child: Text('Bewertung')),
                    const PopupMenuItem(value: ItemSearchRequestSortByEnum.distance, child: Text('Entfernung')),
                    const PopupMenuItem(value: ItemSearchRequestSortByEnum.newest, child: Text('Neueste')),
                  ],
                  child: Chip(
                    label: Text(_sortLabel(filters.sortBy)),
                    avatar: const Icon(Icons.sort, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (hasFilters) {
                  ref.invalidate(searchItemsProvider);
                  await ref.read(searchItemsProvider.future);
                } else {
                  ref.invalidate(featuredItemsProvider);
                  await ref.read(featuredItemsProvider.future);
                }
              },
              child: itemsAsync.when(
                skipLoadingOnReload: true,
                data: (items) => ListView.builder(
                  cacheExtent: 500,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => ItemWidget(items[i], key: ValueKey(items[i].id)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Fehler: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final current = ref.read(searchFiltersProvider).categories;
            return AlertDialog(
              title: const Text('Kategorien'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: dummyCategories.map((cat) {
                    final checked = current.contains(cat);
                    return CheckboxListTile(
                      title: Text(cat),
                      value: checked,
                      onChanged: (_) {
                        ref.read(searchFiltersProvider.notifier).toggleCategory(cat);
                        setDialogState(() {});
                      },
                
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Übernehmen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _sortLabel(ItemSearchRequestSortByEnum sortBy) {
    if (sortBy == ItemSearchRequestSortByEnum.relevance) return 'Beste Treffer';
    if (sortBy == ItemSearchRequestSortByEnum.distance) return 'Entfernung';
    if (sortBy == ItemSearchRequestSortByEnum.newest) return 'Neueste';
    return 'Bewertung';
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback? onClear;
  final Widget Function() childBuilder;

  const _ActiveFilterChip({
    required this.active,
    required this.label,
    required this.icon,
    this.onClear,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (active) {
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        padding: const EdgeInsets.only(left: 4, right: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ),
          ],
        ),
      );
    }
    return childBuilder();
  }
}
